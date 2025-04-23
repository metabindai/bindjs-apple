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
        'props': {
            'modifier': {...modifier},
            'content': content
        }
    }
}

AST.ForEach = (dataId, functionId, count, environmentId, children)  => {
    return {
        'type' : 'ForEach',
        'props': {
            'dataId' : dataId,
            'count' : count,
            'functionId' : functionId,
            'environmentId' : environmentId,
            'children' : children
        }
    }
}

AST.Representable = (functionId, environmentId) => {
    return {
        'type' : 'Representable',
        'functionId' : functionId,
        'environmentId' : environmentId,
    }
}

function isRGBColor(value) {
    return value && typeof value === 'object' && 'r' in value;
}

function isHSLColor(value) {
    return value && typeof value === 'object' && 'h' in value;
}

function isHexColor(value) {
    return typeof value === 'string' && value.startsWith('#');
}

const swiftUIComponentNames = [
    "AngularGradient",
    "AnyView",
    "AsyncImage",
    "Body",
    "Canvas",
    "Circle",
    "ColorPicker",
    "ContentUnavailableView",
    "ControlGroup",
    "ComposerGroup",
    "DatePicker",
    "DisclosureGroup",
    "Divider",
    "EditButton",
    "EllipticalGradient",
    "Ellipse",
    "Capsule",
    "EmptyModifier",
    "EmptyView",
    "EquatableView",
    "EnvironmentValue",
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
    "ReactRepresentable",
    "DOMIdentifable",
    "RadialGradient",
    "Rectangle",
    "RenameButton",
    "RoundedRectangle",
    "ScrollView",
    "ScrollViewReader",
    "Section",
    "SecureField",
    "SettingsLink",
    "Shader",
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

class YapJSRuntime {
    constructor(options) {
        console.log('JSRuntime: init')
        this.options = options ?? { expandForEach: false }
        this.reset()
    }

    reset() {
        console.log('JSRuntime: reset')

        // Add all environment value modifiers that need to be accessible in the environment
        this.modifiersToAddToEnvironment = [
            // Existing modifiers
            'padding',
            'textSelection',
            'font',
            'foregroundStyle',
            'accentColor',
            'controlSize',
            'multilineTextAlignment',
            'lineSpacing',
            'textCase',
            'lineLimit',
            'imageScale',
            'colorScheme',
            
            // EnvironmentValues from Environment.tsx
            'displayScale',
            'dynamicTypeSize',
            'locale',
            'layoutDirection',
            'screen',
            'platform'
        ]

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
        const name = componentName.replace(/\s/g, '')
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
        console.log('registerBuiltInCallbacks')
        this.registerStandardLibrary()
        this.registerEnvironment()
        this.registerUseState()
        this.registerMakeComponent()
        this.registerColor()
        this.registerButton()
    }

    registerStandardLibrary() {
        let funcs = {}
        funcs.capitalize = (s) => {
            return s.charAt(0).toUpperCase() + s.slice(1)
        }
        funcs.reverse = (s) => s.split('').reverse().join('')
        funcs.contains = (s, substr) => s.includes(substr)
        funcs.titleCase = (input) => {
            if (input == undefined) {
                return undefined
            }
            const smallWords = new Set([
                'a', 'an', 'and', 'as', 'at', 'but', 'by', 'for', 'in', 'nor',
                'of', 'on', 'or', 'the', 'to', 'up', 'yet'
            ])
        
            const words = input.trim().split(/\s+/)
        
            return words
                .map((word, i) => {
                    const lower = word.toLowerCase()
        
                    // Always capitalize first and last word
                    if (i === 0 || i === words.length - 1) {
                        return funcs.capitalize(word)
                    }
        
                    // Keep small words lowercase
                    if (smallWords.has(lower)) {
                        return lower
                    }
        
                    return funcs.capitalize(word)
                })
                .join(' ')
        }

        // register all keys in funcs
        for (const key in funcs) {
            this.registerCallback(key, funcs[key])
        }
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

        this.registerCallback('top', () => {
            
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
        // Allow children to be passed as the first argument, including as a single component (function)
        const childrenFirstArg = arg1 != null && arg2 == null && Array.isArray(arg1);
        const singleComponentChild = arg1 != null && arg2 == null && typeof arg1 === 'function' && arg1._component;
        const rawValueFirstArg = typeof arg1 != 'object' && !childrenFirstArg && !singleComponentChild;
        const props =
          rawValueFirstArg ? { rawValue: arg1 }
          : childrenFirstArg ? {}
          : singleComponentChild ? {}
          : arg1;
        const children =
          childrenFirstArg ? arg1
          : singleComponentChild ? [arg1]
          : arg2;
        return { props, children };
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

    #makeEnvironmentValueModifier(name, f) {
        const makeModifier = this.#makeModifier.bind(this)

        return (key, value) => {
            const modifierContent = () => {
                
                /**
                 * Capture environment & run content
                 */
                const capturedEnvironment = {...this.environment}

                // Add this modifier to the environment
                this.environment[key] = value
                
                // Will be a function to an inbuilt when modifying a custom component
                let content = f()
                if (typeof content === 'function') {
                    content = content()
                }

                // Restore environment to previous state
                this.environment = capturedEnvironment

                /**
                 * Construct AST
                 */
                const modifierAST = AST.Directive(name, { environmentKey: key, value }, [])
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
    
    #makePaddingModifier(name, f) {
        const makeModifier = this.#makeModifier.bind(this);
        // SwiftUI default padding value in points
        const DEFAULT_LENGTH = 8;
    
        // Map edge masks, including expansion for composite cases
        function applyEdges(mask, length, target) {
            // Mask can be array or string
            if (typeof mask === "string")
                mask = [mask];
            if (!Array.isArray(mask)) return;
    
            // If "all" is present anywhere, set ALL edges first
            if (mask.includes("all")) {
                target.top = length;
                target.bottom = length;
                target.leading = length;
                target.trailing = length;
                // Don't early-return; individual keys below should override if desired
            }
            for (let edge of mask) {
                switch (edge) {
                    case "top":
                        target.top = length;
                        break;
                    case "bottom":
                        target.bottom = length;
                        break;
                    case "leading":
                        target.leading = length;
                        break;
                    case "trailing":
                        target.trailing = length;
                        break;
                    case "horizontal":
                        target.leading = length;
                        target.trailing = length;
                        break;
                    case "vertical":
                        target.top = length;
                        target.bottom = length;
                        break;
                    // If "all", handled above
                }
            }
        }
    
        // Normalize args to {top, leading, bottom, trailing} number type
        function normalizePaddingArgs(args) {
            let padding = { top: 0, leading: 0, bottom: 0, trailing: 0 };
    
            if (args.length === 0) {
                // .padding() - all sides default
                padding = { top: DEFAULT_LENGTH, leading: DEFAULT_LENGTH, bottom: DEFAULT_LENGTH, trailing: DEFAULT_LENGTH };
            } else if (args.length === 1) {
                const arg = args[0];
                if (typeof arg === 'number' && isFinite(arg)) {
                    // .padding(length)
                    padding = { top: arg, leading: arg, bottom: arg, trailing: arg };
                } else if (typeof arg === 'string') {
                    // .padding(edge)
                    applyEdges([arg], DEFAULT_LENGTH, padding);
                } else if (Array.isArray(arg)) {
                    // .padding(edgeArray)
                    applyEdges(arg, DEFAULT_LENGTH, padding);
                } else if (typeof arg === "object" && arg !== null) {
                    // .padding({ horizontal, vertical, ... })
                    let matched = false;
                    if (typeof arg.horizontal === "number" && isFinite(arg.horizontal)) {
                        padding.leading = arg.horizontal;
                        padding.trailing = arg.horizontal;
                        matched = true;
                    }
                    if (typeof arg.vertical === "number" && isFinite(arg.vertical)) {
                        padding.top = arg.vertical;
                        padding.bottom = arg.vertical;
                        matched = true;
                    }
                    // If explicit edges supplied, use (overrides horizontal/vertical)
                    for (const key of ["top", "leading", "bottom", "trailing"]) {
                        if (typeof arg[key] === "number" && isFinite(arg[key])) {
                            padding[key] = arg[key];
                            matched = true;
                        }
                    }
                    // If nothing matched, fallback to all-DEFAULT_LENGTH
                    if (!matched) {
                        padding = { top: DEFAULT_LENGTH, leading: DEFAULT_LENGTH, bottom: DEFAULT_LENGTH, trailing: DEFAULT_LENGTH };
                    }
                } else {
                    // fallback
                    padding = { top: DEFAULT_LENGTH, leading: DEFAULT_LENGTH, bottom: DEFAULT_LENGTH, trailing: DEFAULT_LENGTH };
                }
            } else if (args.length === 2) {
                // .padding(edges, length)
                let edges = args[0];
                let length = args[1];
                if (!(typeof length === 'number' && isFinite(length))) length = DEFAULT_LENGTH;
                if (typeof edges === "string" || Array.isArray(edges)) {
                    applyEdges(edges, length, padding);
                }
            }
    
            // Cleanup & sanitization: NaN/undefined to 0
            for (const key of ["top", "leading", "bottom", "trailing"]) {
                if (typeof padding[key] !== "number" || !isFinite(padding[key])) padding[key] = 0;
            }
    
            return padding;
        }
    
        return (...args) => {
            const modifierContent = () => {
                const standardizedPadding = normalizePaddingArgs(args);
    
                // Add to environment if required
                const addtoEnv = this.modifiersToAddToEnvironment?.includes(name);
                let capturedEnvironment = null;
                if (addtoEnv) {
                    capturedEnvironment = { ...this.environment };
                    this.environment[name] = standardizedPadding;
                }
                let content = f();
                if (typeof content === 'function') {
                    content = content();
                }
                if (addtoEnv) {
                    this.environment = capturedEnvironment;
                }
                const modifierAST = AST.Directive(name, standardizedPadding, []);
                const ast = AST.ModifiedContent(modifierAST, content);
                return ast;
            };
            return new Proxy(modifierContent, {
                get: function(target, prop, receiver) {
                    if (prop === 'toJSON' || prop === 'type' || prop === 'children' || prop === 'props') {
                        return target[prop];
                    } else {
                        let modifierName = prop;
                        return makeModifier(modifierName, modifierContent, ...arguments);
                    }
                }
            });
        };
    }

    /**
     * Creates a modifier function
     */
    #makeModifier(name, f) {

        if (name === 'environment') {
            return this.#makeEnvironmentValueModifier(name, f)
        }
        
        if (name === 'padding') {
            return this.#makePaddingModifier(name, f)
        }

        const makeModifier = this.#makeModifier.bind(this)

        // If arg is a function, store it and return handler id
        // If arg is props, process them and return props
        const processArg = (arg) => {
            if (arg == null) {
                return {}
            }

            // Arg is a handler function
            if (typeof arg === 'function') {

                // Construct function id from status path
                const { path, childIndex } = this.hookState
                let functionId = [...path, name, childIndex].join(',')

                const handlerId = this.#storeFunction(arg, functionId)
                return { handlerId }

            // Arg is a dictionary of props
            } else if (typeof arg === 'object') {

                return this.#processProps(arg)
            }

            return {}
        }

        return (arg1, arg2) => {
    
            const modifierContent = () => {
    
                // Special handling for event modifiers (on*)
                if (name.startsWith('on')) {

                    // Allow for functions or props to be passed in either argument,
                    // But all get combined into a single props object.
                    let props = {
                        ...processArg(arg1),
                        ...processArg(arg2)
                    }
                            
                    const modifierAST = AST.Directive(name, props, [])
                    const content = f()
                    return AST.ModifiedContent(modifierAST, typeof content === 'function' ? content() : content)
                }

                // Special case: if this is the 'opacity' modifier and the content is a ModifiedComponent with an opacity modifier, multiply and collapse
                if (name === 'opacity') {
                    let content = f();
                    if (typeof content === 'function') content = content();
                    // If the content is a ModifiedComponent with an opacity modifier, collapse
                    if (content && content.type === 'ModifiedComponent' && content.modifier.type === 'opacity') {
                        // Multiply opacities
                        let outerOpacity = arg1;
                        let innerOpacity = content.modifier.props.rawValue !== undefined ? content.modifier.props.rawValue : content.modifier.props;
                        let combinedOpacity = (typeof outerOpacity === 'number' ? outerOpacity : Number(outerOpacity)) * (typeof innerOpacity === 'number' ? innerOpacity : Number(innerOpacity));
                        // The inner content is the Color or next node
                        let innerContent = content.content[0];
                        // If the inner content is a Color node, set its props.opacity and return it directly
                        if (innerContent && innerContent.type === 'Color') {
                            innerContent.props = {
                                ...innerContent.props,
                                opacity: combinedOpacity
                            };
                            return innerContent;
                        }
                        // Otherwise, build a single opacity modifier with the combined value
                        const modifierAST = AST.Directive('opacity', { rawValue: combinedOpacity }, []);
                        return AST.ModifiedContent(modifierAST, innerContent);
                    }
                }

                // Special case: if this is the 'opacity' modifier and the content is a Color
                let isColorContent = false;
                // Try to detect if the content is a Color function/component
                if (name === 'opacity') {
                    let contentCheck = f;
                    if (typeof contentCheck === 'function' && contentCheck._component) {
                        let ast = contentCheck();
                        if (ast && ast.type === 'Color') {
                            isColorContent = true;
                        }
                    }
                }

                var props = arg1 == null ? this.modifierDefaults[name] : arg1

                /**
                 * Capture environment & run content
                 */
                const addtoEnv = this.modifiersToAddToEnvironment?.includes(name)
                var capturedEnvironment = null
                if (addtoEnv) {
                    capturedEnvironment = {...this.environment}
                    this.environment[name] = props
                }
    
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
    
                if (addtoEnv) {
                    this.environment = capturedEnvironment
                }

                // Reset hook state id
                this.hookState.modifierId = null

                props = this.#processProps(props ?? { })

                // Special handling: if this is opacity on Color, always return Color node with multiplied opacity
                if (name === 'opacity' && content && content.type === 'Color') {
                    let newOpacity = props;
                    if (typeof content.props.opacity === 'number' && typeof newOpacity === 'number') {
                        newOpacity = content.props.opacity * newOpacity;
                    }
                    content.props = {
                        ...content.props,
                        opacity: newOpacity
                    };
                    return content; // Return Color node directly
                }

                // Handle passing single value
                if (Array.isArray(props) || typeof props != 'object' || (typeof props == 'object' && props.type != null)) {
                    if (typeof props == 'function') {
                        props = props()
                    }
                    props = { rawValue: props }
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

    #storeFunction(f, functionId) {
        const id = functionId ?? this.#generateUniqueID()
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
            
            const needsStoredEnvironment = type == 'Button' || type == 'ReactRepresentable'
            const environmentId = needsStoredEnvironment ? this.#storeEnvironment(type) : null

            // If props isnt a dictionary contain within value
            if (typeof props != 'object' || typeof props == 'function') {
                props = { rawValue: props }
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
        return result
    }

    registerColor() {
        // Utility to parse hex to rgba
        function hexToRgba(hex) {
            hex = hex.replace(/^#/, '');
            if (hex.length === 3) {
                hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
            } else if (hex.length === 4) {
                hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2]+hex[3]+hex[3];
            }
            let r = 0, g = 0, b = 0, a = 1;
            if (hex.length === 6) {
                r = parseInt(hex.substring(0,2), 16);
                g = parseInt(hex.substring(2,4), 16);
                b = parseInt(hex.substring(4,6), 16);
            } else if (hex.length === 8) {
                r = parseInt(hex.substring(0,2), 16);
                g = parseInt(hex.substring(2,4), 16);
                b = parseInt(hex.substring(4,6), 16);
                a = parseInt(hex.substring(6,8), 16) / 255;
            }
            return { r, g, b, a };
        }
        // Utility to convert HSB/HSV to RGB
        function hsvToRgb(h, s, v) {
            h = ((h % 360) + 360) % 360;
            let c = v * s;
            let x = c * (1 - Math.abs(((h / 60) % 2) - 1));
            let m = v - c;
            let r1 = 0, g1 = 0, b1 = 0;
            if (h < 60)      { r1 = c; g1 = x; b1 = 0; }
            else if (h < 120){ r1 = x; g1 = c; b1 = 0; }
            else if (h < 180){ r1 = 0; g1 = c; b1 = x; }
            else if (h < 240){ r1 = 0; g1 = x; b1 = c; }
            else if (h < 300){ r1 = x; g1 = 0; b1 = c; }
            else             { r1 = c; g1 = 0; b1 = x; }
            const rgb = {
                r: Math.round((r1 + m) * 255),
                g: Math.round((g1 + m) * 255),
                b: Math.round((b1 + m) * 255)
            };
            console.log('DEBUG hsvToRgb input:', { h, s, v }, 'output:', rgb);
            return rgb;
        }
        // The color normalization logic
        function normalizeColor(input) {
            // Handle null/undefined/empty
            if (input == null || (typeof input === 'object' && Object.keys(input).length === 0)) {
                return { r: 0, g: 0, b: 0, a: 1 };
            }
            // Handle number as ARGB integer
            if (typeof input === 'number' && isFinite(input)) {
                // ARGB: 0xAARRGGBB or 0xRRGGBB
                let n = input >>> 0;
                let a, r, g, b;
                if (n > 0xffffff) {
                    a = ((n >> 24) & 0xff) / 255;
                    r = (n >> 16) & 0xff;
                    g = (n >> 8) & 0xff;
                    b = n & 0xff;
                } else {
                    a = 1;
                    r = (n >> 16) & 0xff;
                    g = (n >> 8) & 0xff;
                    b = n & 0xff;
                }
                return { r, g, b, a };
            }
            // Handle string
            if (typeof input === 'string') {
                if (input === 'clear' || input === 'transparent') {
                    return { r: 0, g: 0, b: 0, a: 0 };
                }
                if (isHexColor(input)) {
                    return hexToRgba(input);
                }
                // fallback: return as-is
                return { rawValue: input };
            } else if (typeof input === 'object' && input !== null) {
                // Handle both short and long HSB/HSV keys (not HSL)
                // Only process if 'b' or 'brightness' is present, not 'l'
                if ('h' in input) {
                    console.log('DEBUG normalizeColor HSB candidate:', input);
                }
                const hasShortHSB = 'h' in input && 's' in input && 'b' in input;
                const hasLongHSB = 'hue' in input && 'saturation' in input && 'brightness' in input;
                if (hasShortHSB || hasLongHSB) {
                    let h = input.h ?? input.hue ?? 0;
                    let s = input.s ?? input.saturation ?? 0;
                    let v = input.b ?? input.brightness ?? 0;
                    let a = input.a ?? input.alpha;
                    // s/v in 0-1 or 0-100
                    if (s > 1) s = s / 100;
                    if (v > 1) v = v / 100;
                    console.log('DEBUG normalizeColor HSB input:', input, 'calling hsvToRgb with:', { h, s, v });
                    const rgb = hsvToRgb(h, s, v);
                    return { ...rgb, a: a !== undefined ? a : 1 };
                }
                // Handle both short and long RGB keys, but only if not all of h, s, b are present
                const hasShortRGB = ('r' in input || 'g' in input || 'b' in input) && !(('h' in input) && ('s' in input) && ('b' in input));
                const hasLongRGB = ('red' in input || 'green' in input || 'blue' in input) && !(('hue' in input) && ('saturation' in input) && ('brightness' in input));
                if (hasShortRGB || hasLongRGB) {
                    let r = input.r ?? input.red ?? 0;
                    let g = input.g ?? input.green ?? 0;
                    let b = input.b ?? input.blue ?? 0;
                    let a = input.a ?? input.alpha;
                    // If r/g/b in 0-1, scale to 0-255
                    if (r <= 1 && g <= 1 && b <= 1) {
                        r = Math.round(r * 255);
                        g = Math.round(g * 255);
                        b = Math.round(b * 255);
                    }
                    return { r, g, b, a: a !== undefined ? a : 1 };
                }
                // Handle { opacity } or { a } as alpha for black
                if (
                    (Object.keys(input).length === 1 && ('opacity' in input || 'a' in input)) ||
                    (Object.keys(input).length === 2 && 'opacity' in input && 'a' in input)
                ) {
                    let alpha = input.opacity ?? input.a;
                    return { r: 0, g: 0, b: 0, a: alpha };
                }
            }
            // fallback: return as-is
            return { rawValue: input };
        }
        // Register Color as a component/modifier proxy
        this.context['Color'] = (input) => {
            return this.#makeComponent((props) => {
                // Normalize the color input
                let colorProps = normalizeColor(input);
                // If input is null, undefined, or empty object, return black
                if (
                  input == null ||
                  (typeof input === 'object' && Object.keys(input).length === 0)
                ) {
                  colorProps = { r: 0, g: 0, b: 0, a: 1 };
                }
                // If there is an opacity property, and children[0] is a Color with opacity, multiply
                if (props && typeof props.opacity === 'number' && typeof colorProps.opacity === 'number') {
                  colorProps.opacity = props.opacity * colorProps.opacity;
                } else if (props && typeof props.opacity === 'number') {
                  colorProps.opacity = props.opacity;
                }
                return AST.Directive('Color', colorProps, []);
            }, {}, [], 'Color');
        };
    }

    registerButton() {
        // Robustly detect a YapJS component (proxy function) or any function (for test compatibility)
        const isComponent = (v) => typeof v === 'function';
        // Detect an already-resolved AST node
        const isASTNode = (v) => v && typeof v === 'object' && typeof v.type === 'string';

        // Register Button as a component proxy
        this.context['Button'] = (arg1, arg2) => {
            let action, label;

            // Form 1: Button({action: fn, label: ...})
            if (
                arg1 && typeof arg1 === 'object' &&
                typeof arg1.action === 'function' &&
                (typeof arg1.label === 'string' || isComponent(arg1.label) || isASTNode(arg1.label)) &&
                typeof arg2 === 'undefined'
            ) {
                action = arg1.action;
                label = arg1.label;
            }
            // Form 2: Button(label: string, action: fn)
            else if (
                typeof arg1 === 'string' && typeof arg2 === 'function'
            ) {
                label = arg1;
                action = arg2;
            }
            // Form 3: Button(label: Component, action: fn) or Button(label: ASTNode, action: fn)
            else if (
                (isComponent(arg1) || isASTNode(arg1)) && typeof arg2 === 'function'
            ) {
                label = arg1;
                action = arg2;
            }
            else {
                throw new Error('Button: invalid arguments. Must be one of: Button({action, label}), Button(label: string, action), Button(label: Component, action)');
            }

            // Normalize the label to an AST node
            if (typeof label === 'string') {
                label = this.context.Text(label)();
            }
            // else if it's already an AST node, no change

            // Store the action as a handlerId, similar to on* modifiers
            const { path, childIndex } = this.hookState;
            let functionId = [...path, 'Button', childIndex].join(',');
            const handlerId = this.#storeFunction(action, functionId);

            return this.#makeComponent(
                (props, children) => {
                    // Compose AST for Button
                    return AST.Directive('Button', { handlerId, label }, []);
                },
                {}, [], 'Button'
            );
        };
    }

}










// MARK: - After the runtime...

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

