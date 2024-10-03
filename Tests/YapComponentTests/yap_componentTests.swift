import Testing
import QuartzCore
@testable import YapComponent

// MARK: - Basic Component Tests

@Test func testEmptyComponent() {
    let emptyComponent = EmptyComponent()
    let context = ComponentContext()
    let result = emptyComponent.evaluate(context)
    #expect(result is EmptyComponent)
}

@Test func testPrimitiveComponents() {
    let context = ComponentContext()
    
    let boolComponent: Component = true
    #expect(boolComponent.evaluate(context) as? Bool == true)
    
    let intComponent: Component = 42
    #expect(intComponent.evaluate(context) as? Int == 42)
    
    let doubleComponent: Component = 3.14
    #expect(doubleComponent.evaluate(context) as? Double == 3.14)
    
    let stringComponent: Component = "Hello, World!"
    #expect(stringComponent.evaluate(context) as? String == "Hello, World!")
}

// MARK: - Collection Component Tests

@Test func testArrayComponent() {
    let arrayComponent: Component = [1, "two", true]
    let context = ComponentContext()
    let result = arrayComponent.evaluate(context)
    #expect(result as? [Any] != nil)
    #expect((result as? [Any])?.count == 3)
}

@Test func testDictionaryComponent() {
    let dictComponent: Component = ["a": 1, "b": "two", "c": true]
    let context = ComponentContext()
    let result = dictComponent.evaluate(context)
    #expect(result as? [String: Any] != nil)
    #expect((result as? [String: Any])?.count == 3)
}

// MARK: - Conditional Component Tests

@Test func testConditionalComponentTrueCase() {
    let conditional = ConditionalComponent(condition: true, then: "True", else: "False")
    let context = ComponentContext()
    let result = conditional.evaluate(context)
    #expect(result as? String == "True")
}

@Test func testConditionalComponentFalseCase() {
    let conditional = ConditionalComponent(condition: false, then: "True", else: "False")
    let context = ComponentContext()
    let result = conditional.evaluate(context)
    #expect(result as? String == "False")
}

@Test func testConditionalComponentWithoutElse() {
    let conditional = ConditionalComponent(condition: false, then: "True")
    let context = ComponentContext()
    let result = conditional.evaluate(context)
    #expect(result is EmptyComponent)
}

// MARK: - ForEach Component Tests

@Test func testForEachComponentWithArray() {
    let array: Component = [1, 2, 3]
    let forEach = ForEachComponent(data: array, content: Variable(name: "element"))
    let context = ComponentContext()
    let result = forEach.evaluate(context)
    #expect(result as? [Int] == [1, 2, 3])
}

@Test func testForEachComponentWithEmptyArray() {
    let emptyArray: Component = []
    let forEach = ForEachComponent(data: emptyArray, content: Variable(name: "element"))
    let context = ComponentContext()
    let result = forEach.evaluate(context)
    #expect(result as? [Component] ?? [] == [])
}

// MARK: - Variable Component Tests

@Test func testVariableComponentExistingVariable() {
    let variable = Variable(name: "testVar")
    let context = ComponentContext()
    context.define("testVar", "Hello")
    let result = variable.evaluate(context)
    #expect(result as? String == "Hello")
}

@Test func testVariableComponentNonExistentVariable() {
    let variable = Variable(name: "nonExistent")
    let context = ComponentContext()
    let result = variable.evaluate(context)
    #expect(result is EmptyComponent)
}

// MARK: - Binary Component Tests

@Test func testBinaryComponentArithmetic() {
    let context = ComponentContext()
    
    let addition = Binary(left: 5, op: "+", right: 3)
    #expect(addition.evaluate(context) as? Int == 8)
    
    let subtraction = Binary(left: 10, op: "-", right: 4)
    #expect(subtraction.evaluate(context) as? Int == 6)
    
    let multiplication = Binary(left: 3, op: "*", right: 4)
    #expect(multiplication.evaluate(context) as? Int == 12)
    
    let division = Binary(left: 15, op: "/", right: 3)
    #expect(division.evaluate(context) as? Int == 5)
}

@Test func testBinaryComponentComparison() {
    let context = ComponentContext()
    
    let equal = Binary(left: 5, op: "==", right: 5)
    #expect(equal.evaluate(context) as? Bool == true)
    
    let notEqual = Binary(left: 5, op: "!=", right: 3)
    #expect(notEqual.evaluate(context) as? Bool == true)
    
    let lessThan = Binary(left: 3, op: "<", right: 5)
    #expect(lessThan.evaluate(context) as? Bool == true)
    
    let greaterThan = Binary(left: 7, op: ">", right: 5)
    #expect(greaterThan.evaluate(context) as? Bool == true)
}

@Test func testBinaryComponentLogical() {
    let context = ComponentContext()
    
    let and = Binary(left: true, op: "&&", right: true)
    #expect(and.evaluate(context) as? Bool == true)
    
    let or = Binary(left: false, op: "||", right: true)
    #expect(or.evaluate(context) as? Bool == true)
    
    let not = Binary(left: EmptyComponent(), op: "!", right: false)
    #expect(not.evaluate(context) as? Bool == true)
}

// MARK: - Closure Component Tests

@Test func testClosureComponentSimple() {
    let closure = Closure(parameters: [:], content: "Hello")
    let context = ComponentContext()
    let result = closure.bind(context).callAsFunction()
    #expect(result as? String == "Hello")
}

@Test func testClosureComponentWithParameters() {
    let closure = Closure(parameters: ["greeting": "Hello"], content: Variable(name: "greeting"))
    let context = ComponentContext()
    let result = closure.callAsFunction([:])
    #expect(result as? String == "Hello")
}

@Test func testClosureComponentWithEnclosedContext() {
    let parentContext = ComponentContext()
    parentContext.define("parentVar", "Parent")
    
    let closure = Closure(parameters: [:], content: Variable(name: "parentVar"))
    let boundClosure = closure.bind(parentContext)
    
    let result = boundClosure.callAsFunction([:])
    #expect(result as? String == "Parent")
}

// MARK: - Defaults Component Tests

@Test func testDefaultsComponentFallback() {
    let defaults = Defaults(constants: ["key": "Default"], content: Variable(name: "key"))
    let context = ComponentContext()
    let result = defaults.evaluate(context)
    #expect(result as? String == "Default")
}

// MARK: - Directive Component Tests

@Test func testDirectiveComponentSimple() {
    let directive = Directive(type: "test")
    let context = ComponentContext()
    let result = directive.evaluate(context)
    #expect(result as? Directive != nil)
}

@Test func testDirectiveComponentWithProps() {
    let directive = Directive(type: "test", props: ["key": "value"])
    let context = ComponentContext()
    let result = directive.evaluate(context) as? Directive
    #expect(result?.props["key"] as? String == "value")
}

@Test func testDirectiveComponentWithChildren() {
    let directive = Directive(type: "test", children: ["Child"])
    let context = ComponentContext()
    let result = directive.evaluate(context) as? Directive
    #expect(result?.children.count == 1)
    #expect(result?.children[0] as? String == "Child")
}

// MARK: - Evaluation Tests

@Test func testComponentEvaluationInContext() {
    let context = ComponentContext()
    context.define("var", "Hello")
    
    let component: Component = ConditionalComponent(
        condition: Variable(name: "var").isEqual(to: "Hello"),
        then: "True",
        else: "False"
    )
    
    let result = component.evaluate(context)
    #expect(result as? String == "True")
}

@Test func testNestedComponentEvaluation() {
    let nestedComponent: Component = ConditionalComponent(
        condition: Binary(left: 1, op: "<", right: 2),
        then: ForEachComponent(data: [1, 2, 3], content: Variable(name: "element")),
        else: EmptyComponent()
    )
    
    let context = ComponentContext()
    let result = nestedComponent.evaluate(context)
    #expect(result as? [Int] == [1, 2, 3])
}

// MARK: - Context Tests

@Test func testComponentContextHierarchy() {
    let parentContext = ComponentContext()
    parentContext.define("parentVar", "Parent")
    
    let childContext = ComponentContext(parent: parentContext)
    childContext.define("childVar", "Child")
    
    #expect(childContext.get("parentVar") as? String == "Parent")
    #expect(childContext.get("childVar") as? String == "Child")
    #expect(parentContext.get("childVar") == nil)
}

@Test func testComponentContextVariableAssignment() {
    let context = ComponentContext()
    context.assign("testVar", "Initial")
    #expect(context.get("testVar") as? String == "Initial")
    
    context.assign("testVar", "Updated")
    #expect(context.get("testVar") as? String == "Updated")
}

// MARK: - Equality Tests

@Test func testComponentEquality() {
    let component1: Component = "Test"
    let component2: Component = "Test"
    #expect(component1 == component2)
    
    let array1: Component = [1, 2, 3]
    let array2: Component = [1, 2, 3]
    #expect(array1 == array2)
}

@Test func testComponentInequality() {
    let component1: Component = "Test1"
    let component2: Component = "Test2"
    #expect(component1 != component2)
    
    let array1: Component = [1, 2, 3]
    let array2: Component = [1, 2, 4]
    #expect(array1 != array2)
}

// MARK: - JSON Conversion Tests

@Test func testJSONToComponentConversion() {
    let jsonString = "{\"key\":\"value\",\"array\":[1,2,3]}"
    let component = AnyComponent(from: jsonString)
    let dict = component.unerased as? [String: Any]
    #expect(dict?["key"] as? String == "value")
    #expect(dict?["array"] as? [Int] == [1, 2, 3])
}

@Test func testAnyComponentEquality() {
    let component1 = Directive(type: "Circle").erasedToAnyComponent
    let component2 = Directive(type: "Circle").erasedToAnyComponent
    #expect(component1 == component2)
    
    let component3 = Directive(type: "Rectangle").erasedToAnyComponent
    #expect(component1 != component3)
    
    let component4 = "Test".erasedToAnyComponent
    let component5 = "Test".erasedToAnyComponent
    #expect(component4 == component5)
    
    let component6 = [1, 2, 3].erasedToAnyComponent
    let component7 = [3, 2, 1].erasedToAnyComponent
    #expect(component6 != component7)
    
    let component8 = ["a": 1, "b": 2].erasedToAnyComponent
    let component9 = ["b": 2, "a": 1].erasedToAnyComponent
    #expect(component8 == component9)
    
    let component10 = true.erasedToAnyComponent
    let component11 = false.erasedToAnyComponent
    #expect(component10 != component11)
    
    let component12 = 42.erasedToAnyComponent
    let component13 = 42.0.erasedToAnyComponent
    #expect(component12 != component13)
}

// MARK: - Error Handling Tests

@Test func testErrorHandlingInEvaluation() {
    let component = Binary(left: 1, op: "/", right: 0)  // Division by zero
    let context = ComponentContext()
    let result = component.evaluate(context)
    #expect(result is EmptyComponent)  // Assuming division by zero returns EmptyComponent
}
