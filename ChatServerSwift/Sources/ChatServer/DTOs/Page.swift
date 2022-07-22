import Fluent
import Foundation
import Vapor

struct Page<T: Codable>: Codable, Vapor.Content {
	var items: [T]
	var pagination: Pagination
}

extension Page {
	init(allItems: [T]) {
		self.init(items: allItems, pagination: .init(page: 1, pageCount: 1, pageSize: allItems.count))
	}
}

/// Pagiation metadata for a page. It includes all data required to navigate pages.
struct Pagination: Codable {
	/// The index of the current page. The first page is 1.
	var page: Int
	/// The number of pages in total.
	var pageCount: Int
	/// The number of items to expect on a page.
	var pageSize: Int
	/// If there are pages after the current page, this URL loads the next page.
	var next: URL?
	/// If the current page is not the first page, this URL loads the previous page.
	var previous: URL?
}

extension Pagination {
	init(_ page: PageMetadata, urlFactory: (Pagination) -> URL) {
		self.page = page.page
		self.pageSize = page.per
		self.pageCount = page.total

		if self.page > 1 {
			var previousPage = self
			previousPage.page -= 1
			previous = urlFactory(previousPage)
		}
		if self.page < pageCount {
			var nextPage = self
			nextPage.page += 1
			next = urlFactory(nextPage)
		}
	}
}
