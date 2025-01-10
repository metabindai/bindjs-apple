import SwiftUI
import JavaScriptCore

public struct JSComponent {
    public let name: String
    public let source: String
    
    public init(name: String, source: String) {
        self.name = name
        self.source = source
    }
}

extension EnvironmentValues {
    @Entry public var componentRuntime = ComponentRuntime()
}

public class ComponentRuntime: ObservableObject {
    let value: JSValue
    
    public init(context: JSContext = JSContext()!) {
        
        context.exceptionHandler = { context, exception in
            let message = exception
            print("Error: \(message)")
        }
        
        // Bridge the print function
        let printFunction: @convention(block) (String) -> Void = { message in
            print(message)
        }
        
        let console = ["log": printFunction]
        context.setObject(console, forKeyedSubscript: "console" as NSString)
        
        // Evaluate the main script
        self.value = context.evaluateScript(script)!
        
        // After runtime is created, bridge the needsRerender function
        let needsRerenderFunction: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async {
                withAnimation {
                    self?.objectWillChange.send()
                }
            }
        }
        
        context.setObject(needsRerenderFunction, forKeyedSubscript: "needsRerender" as NSString)
                        
        // Set up the needsRerender function
        context.evaluateScript("runtime.needsRerender = needsRerender")
    }
    
    public func register(_ component: JSComponent) {
        value.invokeMethod("setComponents", withArguments: [[component.name: component.source]])
        objectWillChange.send()
    }
    
    public func view(_ name: String, arguments: [String: Any] = [:]) -> ComponentView {
        willRender()
        if let result = value.invokeMethod("callComponent", withArguments: [[name,  JSValue(object: arguments, in: value.context)]]) {
            return ComponentView(decode(from: result.toString())).runtime(self)
        }
        return ComponentView(EmptyComponent()).runtime(self)
    }
    
    public func environment(_ environment: [String: Any]) -> Self {
        value.invokeMethod("setEnvironment", withArguments: [environment])
        return self
    }
    
    public func restoreEnvironment(id: String) {
        value.invokeMethod("restoreEnvironment", withArguments: [id])
    }
    
    public func restoreFunction(id: String) -> JSValue? {
        if let result = value.invokeMethod("restoreFunction", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func callForEachFunction(id: String, element: JSValue, index: Int32) -> JSValue? {
        setForEachElementId(id: "\(index)")
        
        if let result = value.invokeMethod("callForEachFunction", withArguments: [id, element, index]) {
            return result
        }
        return nil
    }
    
    public func setForEachElementId(id: String) -> Void {
        value.invokeMethod("setForEachElementId", withArguments: [id])
    }
    
    public func restoreEventHandler(id: String) -> JSValue? {
        if let result = value.invokeMethod("restoreEventHandler", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func callEventHandler(id: String, arguments: [Any]) -> JSValue? {
        if let result = value.invokeMethod("callEventHandler", withArguments: [id, arguments]) {
            return result
        }
        return nil
    }
    
    public func restoreForEachData(id: String) -> JSValue? {
        if let result = value.invokeMethod("restoreForEachData", withArguments: [id]) {
            return result
        }
        return nil
    }
    
    public func willRender() {
        value.invokeMethod("willRender", withArguments: [])
    }
    
    @discardableResult
    public func environmentValues(_ environment: EnvironmentValues) -> Self {
        value.invokeMethod("setEnvironment", withArguments: [
            [
                // Core Display Properties
                "displayScale": environment.displayScale,
                "colorScheme": String(describing: environment.colorScheme),
                "colorSchemeContrast": String(describing: environment.colorSchemeContrast),
                "dynamicTypeSize": String(describing: environment.dynamicTypeSize),
                
                // Scene State
                "scenePhase": String(describing: environment.scenePhase),
                
                // Accessibility
                "accessibilityReduceMotion": environment.accessibilityReduceMotion,
                "accessibilityReduceTransparency": environment.accessibilityReduceTransparency,
                "accessibilityDifferentiateWithoutColor": environment.accessibilityDifferentiateWithoutColor,
                "accessibilityInvertColors": environment.accessibilityInvertColors,
                
                // Localization
                "locale": String(describing: environment.locale.identifier),
                "layoutDirection": String(describing: environment.layoutDirection),
            ]
        ])
        return self
    }
    
    public func reset() {
        value.invokeMethod("reset", withArguments: [])
        
        
        // After runtime is created, bridge the needsRerender function
        let needsRerenderFunction: @convention(block) () -> Void = { [weak self] in
            DispatchQueue.main.async {
                withAnimation {
                    self?.objectWillChange.send()
                }
            }
        }
        
        value.context.setObject(needsRerenderFunction, forKeyedSubscript: "needsRerender" as NSString)
                        
        // Set up the needsRerender function
        value.context.evaluateScript("runtime.needsRerender = needsRerender")
    }
}

let script = """
const swiftUIComponentNames = [
    "AngularGradient", "AnyView", "AsyncImage", "Body", "Button", "Canvas", "Capsule", 
    "Circle", "Color", "ColorPicker", "ContentUnavailableView", "ControlGroup", 
    "DatePicker", "DisclosureGroup", "Divider", "EditButton", "EllipticalGradient", 
    "Ellipse", "EmptyModifier", "EmptyView", "EquatableView", "ForEach", "Form", 
    "Gauge", "GeometryReader", "GeometryReader3D", "Grid", "GridRow", "Group", 
    "GroupBox", "HelpLink", "HSplitView", "HStack", "Image", "KeyframeAnimator", 
    "Label", "LazyHGrid", "LazyHStack", "LazyVGrid", "LazyVStack", "LinearGradient", 
    "Link", "List", "Material", "Menu", "MenuButton", "MultiDatePicker", 
    "NavigationLink", "NavigationSplitView", "NavigationStack", "NavigationView", 
    "NewDocumentButton", "PasteButton", "Path", "PhaseAnimator", "Picker", "Polygon", 
    "ProgressView", "RadialGradient", "Rectangle", "RenameButton", "RoundedRectangle", 
    "ScrollView", "ScrollViewReader", "Section", "SecureField", "SettingsLink", 
    "ShareLink", "Shape", "SignInWithAppleButton", "Slider", "Spacer", "Stepper", 
    "Table", "TabView", "Text", "TextEditor", "TextField", "TextFieldLink", "Toggle", 
    "ToolbarItem", "ToolbarItemGroup", "ToolbarTitleMenu", "Triangle", 
    "UnevenRoundedRectangle", "ViewThatFits", "VSplitView", "VStack", 
    "WindowVisibilityToggle", "ZStack"
];

const AST = {} 

AST.Directive = (name, args = {}, children) => {
    var props = {...args}
    props['children'] =  children ?? []
    
    return {
        'type': name,
        'props': props
    }
}

AST.ModifiedContent = (modifier, component) => {

    const content = (Array.isArray(component) ? component : [component])

    return {
        'type': 'ModifiedComponent',
        'modifier': {...modifier},
        'content': content
    }
}

AST.ForEach = (dataId, functionId, count, environmentId, children)  => {
    return {
        'type' : 'ForEach',
        'dataId' : dataId,
        'count' : count,
        'functionId' : functionId,
        'environmentId' : environmentId,
        'children' : children
    }
}


class YapJSRuntime {
    constructor(options) {
        console.log('JSRuntime: init')
        this.options = options ?? { expandForEach: false }
        this.reset()
    }

    reset() {
        console.log('JSRuntime: reset')
        this.context = {}
        this.components = {}
        this.functionCache = {}
        this.modifierFunctions = {}        
        this.callStack = [] 
        this.environment = {}
        this.storedEnvironments = {}
        this.storedFunctions = {}   
        this.storedData = {}
        this.storedHookStates = {}
        this.hookState = {}
        this.resetState()
        this.registerBuiltInCallbacks()
        this.registerASTComponents(swiftUIComponentNames)
        this.registerModifierDefaults()
        this.needsRerender = () => { 
            console.log('Needs rerender not implemented')   
        }
    }

    willRender() {
        this.hookState.path = []
        this.hookState.makeComponentIndex = 0 
        this.hookState.childIndex = 0 
        this.hookState.modifierId = null
        this.hookState.forEachElementId = null
    }

    resetState() {

        console.log('JSRuntime: resetState')

        // Hook state needs to keep track of two things
        // - Component path. A unique path for the current component that's consistent across renders.
        // - Component hook storage. Storage for the hooks based on the component path.
        // - Component hook index. The current index of the hook that is being called
        this.hookState = {
            // Current component path
            path: [],

            // Current index in an array of children. Used to create the path if no id 
            childIndex : 0,

            // Current id set by a modifier. Used to create the path if set.
            modifierId : null,

            // Current id in a ForEach loop. Used to create the path if set.
            forEachElementId: null,

            // Index of the number of calls to makeComponent. Used to generate a unique id for a component if a name isnt available (if called from code)
            makeComponentIndex: 0,

            // Stores the hooks for each component, keyed by path.
            componentHookStore: {},

            // State of the individual for current component
            currentComponent: {
                hookStorage: [],
                hookIndex: 0
            }
        }
    }

    resetStorage() {
        console.log('JSRuntime: resetStorage')

        this.storedEnvironments = {}
        this.storedFunctions = {}   
        this.storedData = {}
        this.storedHookStates = {}
    }
    
    resetCache(componentName) {
        console.log('JSRuntime: resetCache ', componentName)

        this.functionCache[componentName] = {}  
    }

    /**
     * Register the default values for a modifier
     */
    registerModifierDefaults() {
        this.modifierDefaults = {
            'disabled': true,
        }
    }

    registerASTComponents(componentNames) {
        // Construct AST functions for inbuilt components.
        for (const componentName of componentNames) {    
            this.context[componentName] = (props, children, arg3) => {
                return this.#makeInBuiltComponent(componentName, props, children)
            } 
        }

        this.context['ForEach'] = (data, callback) => { 
            return this.#makeForEachComponent(data, callback)
        }
    }

    /**
     * Register the JS of one or more components
     * @param {*} components 
     */
    registerComponents(components, entryPoint = 'body') {    
        for (const componentName of Object.keys(components)) {
            this.registerComponent(componentName, components[componentName], entryPoint)    
        }   
    }

    registerComponent(componentName, content, entryPoint)  {
        const name = componentName.replace(/\\s/g, '')
        this.callStack = [] 
        this.functionCache[name] = {}
        this.components[name] = content

        this.context[name] = (arg1, arg2, ...otherArgs) => {
            const { props, children } = this.#processComponentArgs(arg1, arg2)

            return this.#makeComponent((props, children) => {

               // Call the body of our registered component
               let componentFunction = this.call(name, entryPoint, props, children, ...otherArgs)

               // It's assumed a component returns an inbuilt component.
               // Run the returned function to generate the ast
               let ast = componentFunction()

               if (ast && ast._component) {
                    ast = ast()
               }

               // Wrap the component in a directive so the renderer knows what component generated that part of the AST
               let componentAst = AST.Directive('ComponentCall', { name: name }, [ ast ])

               // Return
               return componentAst

            }, props, children, name)

        }
    }

     /**
     * Register callback to be made available to the runtime
     * @param {*} callbackName
     * @param {*} callback 
     */
    registerCallback(callbackName, callback) {  
        this.context[callbackName] = callback
    }

    /**
     * Register initial environment
     * @param {*} environment 
     */
    registerEnvironment(environment = {}) {  
        this.storedEnvironments = {}
        this.environment = environment
        this.registerCallback('useEnvironment', () => {
            return this.environment
        })
    }

    /**
     * Restores an environment by id
     * @param {*} environmentId 
     */
    restoreEnvironment(environmentId) { 
        let env = this.storedEnvironments[environmentId]
        if (env) {
            this.environment = env
        }

        let hookState = this.storedHookStates[environmentId]    
        if (hookState) {
            this.hookState.path = [...hookState.path]            
        }
    }

    debugEnvironment() {
        console.log('Envionment:')
        console.log(' - Current:', this.environment)
        console.log(' - Stored: ', this.storedEnvironments)
    }


    /**
     * Register built in callbacks available to components
     * @param {*} environment 
     */    
    registerBuiltInCallbacks() {       
        this.registerEnvironment()
        this.registerUseState()
        this.registerMakeComponent()    
    }

    /**
     * Register the 'makeComponent' function available to user code to create a component
     */
    registerMakeComponent() {
        let makeComponent = (component) => {

            // Pass body directly or in dictionary
            let body = component.body ? component.body : component

            // As the name isnt passed in, generate one from the call order
            const componentIndex = this.hookState.makeComponentIndex++

            console.log('registerCallback - makeComponent ', component, componentIndex)

            // Create body function
            let f = (props, children) =>   
                this.#makeComponent((props, children) => body(props, children), props, children, componentIndex)  
            f._component = true
            return f
        }

        this.registerCallback('makeComponent', makeComponent)  
    }

    /**
     * Register the useState hook   
     */
    registerUseState() {
        
        const useState = (initialValue) => {
            // Sanity check
            if (this.hookState.currentComponent == null) {
                return [initialValue, () => {}]
            }

            // Get current state
            var hooks = this.hookState.currentComponent.hookStorage ?? []
            const hookIndex = this.hookState.currentComponent.hookIndex

            //console.log(`useState index ${currentHook} value ${hooks[currentHook]} initialValue ${initialValue}`);
            
            // Initialise hook with initialValue if needed
            hooks[hookIndex] = hooks[hookIndex] == null ? initialValue : hooks[hookIndex]

            const rerenderCallback = this.needsRerender

            // Create setState callback
            let callback = (value) => {

                //console.log(`useState callback value [${value}]`)

                // Update state
                hooks[hookIndex] = value                

                // Trigger a re-render is required due to state changing
                rerenderCallback()
                return value                
            }

            return [hooks[this.hookState.currentComponent.hookIndex++], callback]    
        }

        this.registerCallback('useState', useState.bind(this))
    }

    /**
     * Unregister a component
     * @param {*} componentName
     * @returns
     */
    unregisterComponent(componentName) {
        delete this.components[componentName]
        delete this.functionCache[componentName]
        delete this.context[componentName]  
    }

    /**
     * Calls the main body of a component for rendering the AST
     */
    callComponent(componentName, params, children, ...args) {
        let body = this.context[componentName];
        if (body) {
            let b = body(params, children, ...args);  
            if (typeof b === 'function' && b._component) {
                return b()
            }
        } 
        return null
    } 

    /**
     * Calls a function within a registered component
     * @param {*} componentName 
     * @param {*} componentEntryPoint 
     * @returns 
     */
    call(componentName, componentEntryPoint = 'body', params, children, ...args) {
        const componentKeys = Object.keys(this.context);
        const functionList = componentKeys.join(', ');
    
        let func = null
        if (this.functionCache[componentName] && this.functionCache[componentName][componentEntryPoint]) {  
            //console.log(`[cache hit ${componentName}.${componentEntryPoint}]`)
            func = this.functionCache[componentName][componentEntryPoint]
        } else {
            //console.log(`[constructing ${componentName}.${componentEntryPoint}]`)
            func = new Function(`{ ${functionList} }`, `${this.components[componentName]}; return ${componentEntryPoint}`)(this.context);
            this.functionCache[componentName][componentEntryPoint] = func   
        }

        return func(params, children, ...args)
    }


    /**
     * Process arguments for a component
     * @param {*} arg1 
     * @param {*} arg2 
     * @returns 
     */
    #processComponentArgs(arg1, arg2) {  
        // Allow children to be passed as the first argument.
        // If single value or array is passed then it becomes the children.
        // TODO: Discuss, single value be children or rawValue/value ?
        const childrenFirstArg = arg1 != null && arg2 == null && (Array.isArray(arg1))
        const rawValueFirstArg = typeof arg1 != 'object' && !childrenFirstArg

        const props    = rawValueFirstArg ? { value: arg1 } : (childrenFirstArg ? {} : arg1)
        const children = childrenFirstArg ? arg1 : arg2

        return { props, children }        
    }

    /**
     * Process the props for a component or a modifier ,expanding functions in arrays or values
     * @param {*} props 
     * @returns 
     */
    #processProps(props) { 
        if (props == null || typeof props != 'object') {  
            return props
        }
        
        var newProps = {...props}
        Object.keys(newProps).forEach(key => {
            let value = newProps[key]
            
            // Expand functions in arrays
            if (Array.isArray(value)) {
                newProps[key] = value.map(v => 
                    (typeof v === 'function' && v._component) ? v() : v
                )

            // Expand functions if value of key 
            } if (typeof newProps[key] === 'function' && newProps[key]._component) {
                newProps[key] = newProps[key]()
            } 
        })
        return newProps
    }


    /**
     * Creates a modifier function
     */
    #makeModifier(name, f) {
    
        const makeModifier = this.#makeModifier.bind(this)    

        return (modifierProps) => {
    
            const modifierContent = () => {
    
                // Special handling for event modifiers (on*)
                if (name.startsWith('on')) {
                    let props = {}
                    
                    // Handle different argument patterns
                    if (typeof modifierProps === 'function') {
                        // Just a handler function
                        const handlerId = this.#storeFunction(modifierProps)
                        props = { handlerId }
                    } else if (typeof modifierProps === 'object') {
                        // Object with handler and additional props
                        if (typeof modifierProps.handler === 'function') {
                            const handlerId = this.#storeFunction(modifierProps.handler)
                            props = {
                                ...modifierProps,
                                handler: undefined,
                                handlerId // Add the handler ID
                            }
                            delete props.handler  // Remove the function
                        } else {
                            props = this.#processProps(modifierProps)
                        }
                    }

                    const modifierAST = AST.Directive(name, props, [])
                    const content = f()
                    return AST.ModifiedContent(modifierAST, typeof content === 'function' ? content() : content)
                }

                // Regular modifier handling remains the same

                // If no props are passed, assume a value true
                var props = modifierProps == null ? this.modifierDefaults[name] : modifierProps

                /**
                 * Capture environment & run content
                 */
                const capturedEnvironment = {...this.environment}
                this.environment[name] = props
    
                // If this modifier is an id, store the name into the hook state so it can be used 
                // for the hook path
                if (name == 'id') {
                    this.hookState.modifierId = props
                }

                // Will be a function to an inbuilt when modifying a custom component
                let content = f()
                if (typeof content === 'function') {    
                    content = content()
                }
    
                this.environment = capturedEnvironment

                // Reset hook state id
                this.hookState.modifierId = null

                
                props = this.#processProps(props ?? { })

                // Handle passing single value
                if (Array.isArray(props) || typeof props != 'object' || (typeof props == 'object' && props.type != null)) { 
                    // If passing a component, execute it to get the ast 
                    if (typeof props == 'function') {
                        props = props()
                    }
                    props = { value: props }
                }
                

                /**
                 * Construct AST    
                 */
                const modifierAST = AST.Directive(name, props, [])
                const ast = AST.ModifiedContent(modifierAST, content )
    
                return ast
            }
            
            return new Proxy(modifierContent, {   
                get: function(target, prop, receiver) {
                    if (prop == 'toJSON' || prop == 'type' || prop == 'children' || prop == 'props') {
                        return target[prop]
                    } else {
                        let modifierName = prop
                        return makeModifier(modifierName, modifierContent, ...arguments)
                    }
                }    
            })
        }
    }

    makeComponent(body, props, children) { 
        return this.#makeComponent(body, props, children)
    }
    
    /**
     * Creates a component
     */
    #makeComponent(body, props, children, componentName) {
        
        const f = () => {

            let { path, modifierId, childIndex, componentHookStore, currentComponent, forEachElementId } = this.hookState

            // Push on to hook state path
            // Use id if specified otherwise use child index + component name to create a deterministct path to that item.
            var id = null
            if (modifierId) {
                id = modifierId
            } else if (forEachElementId) {
                id = forEachElementId
            } else {
                id = componentName + '_' + childIndex
            }
            path.push(id)

            // Create path key. This is a unique key consistent across renders
            let hookKey = path.join('.')

            // Get hook storage for this component
            let hookStorage = componentHookStore[hookKey] ?? (componentHookStore[hookKey] = []);

            // Setup component hook state for the component we're about to call
            currentComponent.hookStorage = hookStorage            
            currentComponent.hookIndex = 0

            // Call the content function
            let r = body(props, children)

            // Reset
            currentComponent.hookStorage = null
            path.pop()

            return r
        }
        
        f._component = true

        const makeModifier = this.#makeModifier.bind(this)

        return new Proxy(f, {
            get: function(target, prop, receiver) {
                if (prop == 'toJSON' || prop == 'type' || prop == 'children' || prop == 'props') {
                    return target[prop]
                }
                return makeModifier(prop, f, ...arguments)
            }
        })
    }

    #generateUniqueID() {   
        return Math.random().toString(36).substring(7)   
    }

    #storeEnvironment(typeName) { 
        const id = this.#generateUniqueID()
        if (this.environment) {
            this.storedEnvironments[id] = {...this.environment}
        }
        if (this.hookState) {
            this.storedHookStates[id] = { path: [...this.hookState.path] } 
        }
        return id
    }

    restoreFunction(functionId) {   
        return this.storedFunctions[functionId]
    }

    #storeFunction(f) {
        const id = this.#generateUniqueID()
        this.storedFunctions[id] = f    
        return id
    }

    restoreData(dataId) {   
        return this.storedData[dataId]
    }

    #storeData(data) {
        const id = this.#generateUniqueID()
        this.storedData[id] = data  
        return id
    }

    setForEachElementId(id) {
        this.hookState.forEachElementId = id
    }

    /**
     * Create a ForEach component
     */
    #makeForEachComponent(data, callback) {
        let expand = this.options.expandForEach
        return this.#makeComponent((data, callback) => {

            let count      = Array.isArray(data) ? data.length : 0   

            if (expand) {
                let children = data.map((element, index) => {   
                    this.setForEachElementId(index)
                    let result = callback(element, index)
                    while(result && result._component) {
                        result = result()
                    }
                    return result
                })
                return AST.ForEach(null, null, count, null, children)  
            } else {
                let environmentId = this.#storeEnvironment()
                let functionId = this.#storeFunction(callback)
                let dataId     = this.#storeData(data)

                return AST.ForEach(dataId, functionId, count, environmentId)  
            }
        }, data, callback, 'ForEach')   
    }

    /**
    * Creates a built in component
    */
    #makeInBuiltComponent(type, props, children) {
        
        return this.#makeComponent((componentProps, componentChildren) => {
            
            var {props, children} = this.#processComponentArgs(componentProps, componentChildren)
  
            props = props ?? {}    
            
            var environmentId = this.#storeEnvironment(type)

            // If props isnt a dictionary contain within value
            if (typeof props != 'object' || typeof props == 'function') { 
                props = { value: props }
            }

            // Expand function in props 
            props = this.#processProps(props)  
            
            /**
             * Execute children
             */
            const childrenAST = (children ?? []).flatMap((child, index) => {
                this.hookState.childIndex = index

                let content = typeof child === 'function' ? child() : child             
                if (typeof content === 'function') {
                    content = content()
                }
                return content
            } )

            // Reset
            this.hookState.childIndex = 0

            /**
             * Component AST
             */
            return AST.Directive(type, {...props, environmentId: environmentId}, childrenAST)  
        }, props, children, type) 
    }

    /**
     * 
     * Calls the contents of a ForEach function with a specific element and index.
     * 
     * @param {string} functionId 
     * @param {string?} environmentId 
     * @param {any} element 
     * @param {number} index 
     * @returns 
     */
    callForEachFunction(functionId, element, index) {
        let f = this.restoreFunction(functionId)
        let result = f(element, index)
        while(result && result._component) {
            result = result()
        }
        this.hookState.forEachElementId = null
        return result
    }

}






const runtime = new YapJSRuntime();

Object.assign(this, {
    setComponents: (args) => runtime.registerComponents(args),
    setASTComponents: (components, modifiers) => runtime.registerASTComponents(components, modifiers),
    call: (args) => JSON.stringify(runtime.call(...args)(), null, 2),
    callComponent: (args) => JSON.stringify(runtime.callComponent(...args), null, 2),
    setEnvironment: (environment) => runtime.registerEnvironment(environment),
    makeComponent: (body, props, children) => runtime.makeComponent(body, props, children),
    restoreEnvironment: (environmentId) => runtime.restoreEnvironment(environmentId),
    restoreFunction: (functionId) => runtime.restoreFunction(functionId),
    setForEachElementId: (id) => runtime.setForEachElementId(id),
    callForEachFunction: (functionId, element, index) => JSON.stringify(runtime.callForEachFunction(functionId, element, index), null, 2),
    restoreForEachData: (dataId) => runtime.restoreData(dataId),
    restoreEventHandler: (handlerId) => runtime.restoreEventHandler(handlerId),
    callEventHandler: (handlerId, ...args) => {
        const handler = runtime.storedFunctions[handlerId]
        if (handler) {
            return handler(...args)
        }
        return null
    },
    willRender: () => runtime.willRender(),
    debug: () => console.log(JSON.stringify(runtime.components)),
    reset: () => runtime.reset(),
});
"""
