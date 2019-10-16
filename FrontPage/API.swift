//  This file was automatically generated and should not be edited.

import Apollo

public enum TaskStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case `open`
  case assigned
  case complete
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "OPEN": self = .open
      case "ASSIGNED": self = .assigned
      case "COMPLETE": self = .complete
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .open: return "OPEN"
      case .assigned: return "ASSIGNED"
      case .complete: return "COMPLETE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: TaskStatus, rhs: TaskStatus) -> Bool {
    switch (lhs, rhs) {
      case (.open, .open): return true
      case (.assigned, .assigned): return true
      case (.complete, .complete): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [TaskStatus] {
    return [
      .open,
      .assigned,
      .complete,
    ]
  }
}

public final class DeleteTaskMutation: GraphQLMutation {
  /// mutation deleteTask($id: ID!) {
  ///   deleteTask(id: $id)
  /// }
  public let operationDefinition =
    "mutation deleteTask($id: ID!) { deleteTask(id: $id) }"

  public let operationName = "deleteTask"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteTask", arguments: ["id": GraphQLVariable("id")], type: .scalar(GraphQLID.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteTask: GraphQLID? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteTask": deleteTask])
    }

    public var deleteTask: GraphQLID? {
      get {
        return resultMap["deleteTask"] as? GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteTask")
      }
    }
  }
}

public final class CreateTaskMutation: GraphQLMutation {
  /// mutation createTask($title: String!, $description: String!, $status: TaskStatus!) {
  ///   createTask(title: $title, description: $description, status: $status) {
  ///     __typename
  ///     ...TaskFields
  ///   }
  /// }
  public let operationDefinition =
    "mutation createTask($title: String!, $description: String!, $status: TaskStatus!) { createTask(title: $title, description: $description, status: $status) { __typename ...TaskFields } }"

  public let operationName = "createTask"

  public var queryDocument: String { return operationDefinition.appending(TaskFields.fragmentDefinition) }

  public var title: String
  public var description: String
  public var status: TaskStatus

  public init(title: String, description: String, status: TaskStatus) {
    self.title = title
    self.description = description
    self.status = status
  }

  public var variables: GraphQLMap? {
    return ["title": title, "description": description, "status": status]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createTask", arguments: ["title": GraphQLVariable("title"), "description": GraphQLVariable("description"), "status": GraphQLVariable("status")], type: .object(CreateTask.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createTask: CreateTask? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createTask": createTask.flatMap { (value: CreateTask) -> ResultMap in value.resultMap }])
    }

    public var createTask: CreateTask? {
      get {
        return (resultMap["createTask"] as? ResultMap).flatMap { CreateTask(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createTask")
      }
    }

    public struct CreateTask: GraphQLSelectionSet {
      public static let possibleTypes = ["Task"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(TaskFields.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, title: String, version: Int? = nil, description: String, status: TaskStatus? = nil) {
        self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "version": version, "description": description, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var taskFields: TaskFields {
          get {
            return TaskFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class DeleteSubscription: GraphQLSubscription {
  /// subscription delete {
  ///   taskDeleted {
  ///     __typename
  ///     ...TaskFields
  ///   }
  /// }
  public let operationDefinition =
    "subscription delete { taskDeleted { __typename ...TaskFields } }"

  public let operationName = "delete"

  public var queryDocument: String { return operationDefinition.appending(TaskFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("taskDeleted", type: .object(TaskDeleted.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(taskDeleted: TaskDeleted? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "taskDeleted": taskDeleted.flatMap { (value: TaskDeleted) -> ResultMap in value.resultMap }])
    }

    public var taskDeleted: TaskDeleted? {
      get {
        return (resultMap["taskDeleted"] as? ResultMap).flatMap { TaskDeleted(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "taskDeleted")
      }
    }

    public struct TaskDeleted: GraphQLSelectionSet {
      public static let possibleTypes = ["Task"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(TaskFields.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, title: String, version: Int? = nil, description: String, status: TaskStatus? = nil) {
        self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "version": version, "description": description, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var taskFields: TaskFields {
          get {
            return TaskFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class AddSubscription: GraphQLSubscription {
  /// subscription add {
  ///   taskAdded {
  ///     __typename
  ///     ...TaskFields
  ///   }
  /// }
  public let operationDefinition =
    "subscription add { taskAdded { __typename ...TaskFields } }"

  public let operationName = "add"

  public var queryDocument: String { return operationDefinition.appending(TaskFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("taskAdded", type: .object(TaskAdded.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(taskAdded: TaskAdded? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "taskAdded": taskAdded.flatMap { (value: TaskAdded) -> ResultMap in value.resultMap }])
    }

    public var taskAdded: TaskAdded? {
      get {
        return (resultMap["taskAdded"] as? ResultMap).flatMap { TaskAdded(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "taskAdded")
      }
    }

    public struct TaskAdded: GraphQLSelectionSet {
      public static let possibleTypes = ["Task"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(TaskFields.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, title: String, version: Int? = nil, description: String, status: TaskStatus? = nil) {
        self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "version": version, "description": description, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var taskFields: TaskFields {
          get {
            return TaskFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class AllTasksQuery: GraphQLQuery {
  /// query allTasks {
  ///   allTasks {
  ///     __typename
  ///     ...TaskFields
  ///   }
  /// }
  public let operationDefinition =
    "query allTasks { allTasks { __typename ...TaskFields } }"

  public let operationName = "allTasks"

  public var queryDocument: String { return operationDefinition.appending(TaskFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("allTasks", type: .list(.object(AllTask.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(allTasks: [AllTask?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "allTasks": allTasks.flatMap { (value: [AllTask?]) -> [ResultMap?] in value.map { (value: AllTask?) -> ResultMap? in value.flatMap { (value: AllTask) -> ResultMap in value.resultMap } } }])
    }

    public var allTasks: [AllTask?]? {
      get {
        return (resultMap["allTasks"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [AllTask?] in value.map { (value: ResultMap?) -> AllTask? in value.flatMap { (value: ResultMap) -> AllTask in AllTask(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [AllTask?]) -> [ResultMap?] in value.map { (value: AllTask?) -> ResultMap? in value.flatMap { (value: AllTask) -> ResultMap in value.resultMap } } }, forKey: "allTasks")
      }
    }

    public struct AllTask: GraphQLSelectionSet {
      public static let possibleTypes = ["Task"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(TaskFields.self),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, title: String, version: Int? = nil, description: String, status: TaskStatus? = nil) {
        self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "version": version, "description": description, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var taskFields: TaskFields {
          get {
            return TaskFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public struct TaskFields: GraphQLFragment {
  /// fragment TaskFields on Task {
  ///   __typename
  ///   id
  ///   title
  ///   version
  ///   description
  ///   status
  /// }
  public static let fragmentDefinition =
    "fragment TaskFields on Task { __typename id title version description status }"

  public static let possibleTypes = ["Task"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("title", type: .nonNull(.scalar(String.self))),
    GraphQLField("version", type: .scalar(Int.self)),
    GraphQLField("description", type: .nonNull(.scalar(String.self))),
    GraphQLField("status", type: .scalar(TaskStatus.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: GraphQLID, title: String, version: Int? = nil, description: String, status: TaskStatus? = nil) {
    self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "version": version, "description": description, "status": status])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var title: String {
    get {
      return resultMap["title"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  public var version: Int? {
    get {
      return resultMap["version"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "version")
    }
  }

  public var description: String {
    get {
      return resultMap["description"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  public var status: TaskStatus? {
    get {
      return resultMap["status"] as? TaskStatus
    }
    set {
      resultMap.updateValue(newValue, forKey: "status")
    }
  }
}
