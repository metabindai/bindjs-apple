import SwiftUI
import JavaScriptCore

public struct JSComponent {
    let name: String
    let source: String
    
    public init(name: String, source: String) {
        self.name = name
        self.source = source
    }
}

extension EnvironmentValues {
    @Entry var componentRuntime = ComponentRuntime()
}

public class ComponentRuntime: ObservableObject {
    let value: JSValue
    
    public init(context: JSContext = JSContext()!) {
        
        context.exceptionHandler = { context, exception in
            let message = exception
            print("Error: \(message)")
        }
        
        self.value = context.evaluateScript(script)!
    }
    
    public func register(_ component: JSComponent) {
        value.invokeMethod("setComponents", withArguments: [[component.name: component.source]])
        objectWillChange.send()
    }
    
    public func view(_ name: String, arguments: [String: Any] = [:]) -> some View {
        if let result = value.invokeMethod("call", withArguments: [[name, "body", JSValue(object: arguments, in: value.context)]]) {
            return ComponentView(decode(from: result.toString()))
                .environment(\.componentRuntime, self)
        }
        return ComponentView(EmptyComponent())
            .environment(\.componentRuntime, self)
    }
    
    public func environment(_ environment: [String: Any]) {
        value.invokeMethod("setEnvironment", withArguments: [environment])
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
    
    public func callRestoreFunction(id: String, element: JSValue, index: Int32) -> JSValue? {
        if let result = value.invokeMethod("callRestoreFunction", withArguments: [id, element, index]) {
            return result
        }
        return nil
    }
    
    public func restoreData(id: String) -> JSValue? {
        if let result = value.invokeMethod("restoreData", withArguments: [id]) {
            return result
        }
        return nil
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
                "layoutDirection": String(describing: environment.layoutDirection)
            ]
        ])
        return self
    }
    
    public func reset() {
        value.invokeMethod("reset", withArguments: [])
    }
}

let script = """
const swiftUIComponentNames = [
    "AngularGradient",
    "AnyView",
    "AsyncImage",
    "Body",
    "Button",
    "Canvas",
    "Capsule",
    "Circle",
    "Color",
    "ColorPicker",
    "ContentUnavailableView",
    "ControlGroup",
    "DatePicker",
    "DisclosureGroup",
    "Divider",
    "EditButton",
    "EllipticalGradient",
    "Ellipse",
    "EmptyModifier",
    "EmptyView",
    "EquatableView",
    "ForEach",
    "Form",
    "Gauge",
    "GeometryReader",
    "GeometryReader3D",
    "Grid",
    "GridRow",
    "Group",
    "GroupBox",
    "HelpLink",
    "HSplitView",
    "HStack",
    "Image",
    "KeyframeAnimator",
    "Label",
    "LazyHGrid",
    "LazyHStack",
    "LazyVGrid",
    "LazyVStack",
    "LinearGradient",
    "Link",
    "List",
    "Material",
    "Menu",
    "MenuButton",
    "MultiDatePicker",
    "NavigationLink",
    "NavigationSplitView",
    "NavigationStack",
    "NavigationView",
    "NewDocumentButton",
    "PasteButton",
    "Path",
    "PhaseAnimator",
    "Picker",
    "ProgressView",
    "RadialGradient",
    "Rectangle",
    "RenameButton",
    "RoundedRectangle",
    "ScrollView",
    "ScrollViewReader",
    "Section",
    "SecureField",
    "SettingsLink",
    "ShareLink",
    "Shape",
    "SignInWithAppleButton",
    "Slider",
    "Spacer",
    "Stepper",
    "Table",
    "TabView",
    "Text",
    "TextEditor",
    "TextField",
    "TextFieldLink",
    "Toggle",
    "ToolbarItem",
    "ToolbarItemGroup",
    "ToolbarTitleMenu",
    "UnevenRoundedRectangle",
    "ViewThatFits",
    "VSplitView",
    "VStack",
    "WindowVisibilityToggle",
    "ZStack"
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

AST.ForEach = (dataId, functionId, count)  => {
    return {
        'type' : 'ForEach',
        'dataId' : dataId,
        'count' : count,
        'functionId' : functionId
    }
}

class YapJSRuntime {
    constructor(options) {
        this.options = options ?? { expandAll: true }
        this.reset()
    }

    reset() {
        this.context = {}
        this.components = {}
        this.functionCache = {}
        this.modifierFunctions = {}        
        this.callStack = [] 
        this.environment = {}
        this.storedEnvironments = {}
        this.storedFunctions = {}   
        this.storedData = {}
        this.registerBuiltInCallbacks()
        this.registerASTComponents(swiftUIComponentNames)
        this.registerModifierDefaults()

    }

    resetStorage() {
        this.storedEnvironments = {}
        this.storedFunctions = {}   
        this.storedData = {}
    }
    
    resetCache(componentName) {
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

               // Wrap the component in a directive so the renderer knows what component generated that part of the AST
               let componentAst = AST.Directive('ComponentCall', { name: name }, [ ast ])

               // Return
               return componentAst

            }, props, children)

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
        this.registerCallback('makeComponent', (component) => {
            // Pass body directly or in dictionary
            let body = component.body ? component.body : component
        
            // Create body function
            return (props, children) =>   
                this.#makeComponent((props, children) => body(props, children), props, children)    
        })  
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
     * Calls the body of a component
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
            console.log(`[constructing ${componentName}.${componentEntryPoint}]`)
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
                    (typeof v === 'function') ? v() : v
                )

            // Expand functions if value of key 
            } if (typeof newProps[key] === 'function') {
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
    
                // If no props are passed, assume a value true
                var props = modifierProps == null ? this.modifierDefaults[name] : modifierProps

                /**
                 * Capture environment & run content
                 */
                const capturedEnvironment = {...this.environment}
                this.environment[name] = props
    
                // Will be a function to an inbuilt when modifying a custom component
                let content = f()
                if (typeof content === 'function') {    
                    content = content()
                }
    
                this.environment = capturedEnvironment
    
                
                
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
    #makeComponent(body, props, children) {
        const f = () => 
            body(props, children)

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

    /**
     * Create a ForEach component
     */
    #makeForEachComponent(data, callback) {
        return this.#makeComponent((data, callback) => {
            
            let functionId = this.#storeFunction(callback)
            let dataId     = this.#storeData(data)
            let count      = Array.isArray(data) ? data.length : 0   

            return AST.ForEach(dataId, functionId, count)  

        }, data, callback)
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
            const childrenAST = (children ?? []).flatMap(child => {
                let content = typeof child === 'function' ? child() : child             
                if (typeof content === 'function') {
                    content = content()
                }
                return content
            } )

            /**
             * Component AST
             */
            return AST.Directive(type, {...props, environmentId: environmentId}, childrenAST)  
        }, props, children) 
    }
}


// Export the runtime interface
const runtime = new YapJSRuntime();

Object.assign(this, {
    setComponents: (args) => runtime.registerComponents(args),
    setASTComponents: (components, modifiers) => runtime.registerASTComponents(components, modifiers),
    call: (args) => JSON.stringify(runtime.call(...args)(), null, 2),
    setEnvironment: (environment) => runtime.registerEnvironment(environment),
    makeComponent: (body, props, children) => runtime.makeComponent(body, props, children),
    restoreEnvironment: (environmentId) => runtime.restoreEnvironment(environmentId),
    restoreFunction: (functionId) => runtime.restoreFunction(functionId),
    callRestoreFunction: (functionId, element, index) => {
        let f = runtime.restoreFunction(functionId)
        let result = f(element, index)
        return JSON.stringify(result(), null, 2)
    },
    restoreData: (dataId) => runtime.restoreData(dataId),
});

"""
