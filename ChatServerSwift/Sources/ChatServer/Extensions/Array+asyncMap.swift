extension Array {
	func asyncMap<U>(_ fn: @escaping (Element) async throws -> U) async rethrows -> [U] {
		try await withThrowingTaskGroup(of: U.self) {
			for element in self {
				$0.addTask {
					try await fn(element)
				}
			}

			var results: [U] = []
			for try await element in $0 {
				results.append(element)
			}
			return results
		}
	}
}
