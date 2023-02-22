import Vapor
import BSON
import Fluent
import JWT
import AddaSharedModels

public func categoriesHandler(request: Request, route: CategoriesRoute) async throws -> AsyncResponseEncodable {
    switch route {
    case .create(let input):
        let category = CategoryModel(name: input.name)
        try await category.save(on: request.db)
        return category.response

    case .list:

        let categories = try await CategoryModel.query(on: request.db).all()
        let response = categories.map {
            return CategoryResponse(
                id: $0.id ?? ObjectId(),
                name: $0.name,
                url: request.application.router
                    .url(for: .eventEngine(.categories(.category(id: $0.id!.hexString, .find))))
            )
        }
        return CategoriesResponse(categories: response)
        
    case .update(let originalCatrgory):
        
        if request.loggedIn == false { throw Abort(.unauthorized) }

        let category = try await CategoryModel.query(on: request.db)
            .filter(\.$id == originalCatrgory.id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "No Category. found! by ID: \(originalCatrgory.id)"))
            .get()
        

        category.name = originalCatrgory.name

        try await category.update(on: request.db)
        return category.response
        
    case .delete(id: let id):
        
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        guard let id = ObjectId(id) else {
            throw Abort(.notFound)
        }
        
        let category = try await CategoryModel.find(id, on: request.db)
            .unwrap(or: Abort(.notFound, reason: "Cant find Category by id: \(id) for delete"))
            .get()
        try await category.delete(force: true, on: request.db)
        return HTTPStatus.ok
    case let .category(id: id, categoryRoute):
        return try await categoryHandler(
            request: request,
            categoryId: id,
            route: categoryRoute
        )
    }
}


public func categoryHandler(
    request: Request,
    categoryId: String,
    route: CategoryRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .find:
        return Response(status: .badRequest)
    }
}
