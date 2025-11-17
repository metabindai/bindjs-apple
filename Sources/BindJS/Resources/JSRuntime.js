const AST = {};

AST.Directive = (name, args = {}, children) => {
    var props = {...args};
    props['children'] =  children ?? [];
    
    return {
        'type': name,
        'props': props
    }
};

AST.ModifiedContent = (modifier, component) => {

    const content = (Array.isArray(component) ? component : [component]);

    return {
        'type': 'ModifiedComponent',
        'props': {
            'modifier': {...modifier},
            'content': content
        }
    }
};

AST.ForEach = (dataId, functionId, count, environmentId, children)  => {
    return {
        'type' : 'ForEach',
        'props': {
            'dataId': dataId,
            'functionId': functionId,
            'count': count,
            'environmentId': environmentId,
            'children': children
        }
    }
};

AST.Representable = (functionId, environmentId) => {
    return {
        'type' : 'Representable',
        'props': {
            'functionId': functionId,
            'environmentId': environmentId
        }
    }
};

function Color({ args }) {

    const [props] = args ?? [];

    let colorProps;
    // If input is null, undefined, or empty object, return black
    if (props == null || (typeof props === 'object' && Object.keys(props).length === 0)) {
        colorProps = { r: 0, g: 0, b: 0, a: 1 };
    } else {
        // Normalize the color input
        colorProps = normalizeColor(props);
    }
    

    return { props: colorProps, children: [] }
}

function isHexColor(value) {
    return typeof value === 'string' && value.startsWith('#');
}

function isNamedColor(value) {
    return typeof value === 'string' && !isHexColor(value)
}

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
        // Named/semantic color
        if (isNamedColor(input)) {
            return { rawValue: input };
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

function Button({ args }) {
    const [arg1, arg2] = args;

    // Normalize into { action, label }
    // If a single arg is passed and it's an object, use it as { action, label }
    // If two args are passed, use the first as label and the second as action
    const { action, label } = typeof arg1 === 'object' && Object.keys(arg1).length > 0
                                        ? arg1
                                        : { label: arg1, action: arg2  };


                                        
    // Store the action, get the handlerId to be provided in the AST props.
    const path = this.currentPathId();
    const handlerId = this.storeFunction(action, path);
    const environmentId = this.storeEnvironment(path);
       
    // Process label
    const { label: finalLabel } = this.processProps({ label });

    return {
        props: { handlerId, label: finalLabel, environmentId },
        children: []
    }
    
}

function GenericComponent({ args }) {
    var { props, children } = processComponentArgs(args[0], args[1]);

    // If props isnt a dictionary contain within value
    if (typeof props != 'object' || typeof props == 'function') {
        props = { rawValue: props };
    }

    // Expand functions in props
    props = this.processProps(props);

    /**
     * Execute children
     */
    const childrenAST = processChildren.bind(this)(children);

    return { props, children: childrenAST }
}

function processChildren(children) {
    if (!children) {
        return [];
    }

    /**
     * Execute children
     */
    const childrenAST = (children ?? []).flatMap((child, index) => {
        this.hookState.childIndex = index;

        let content = typeof child === 'function' ? child() : child;
        if (typeof content === 'function') {
            content = content();
        }
        return content
    });

    // Reset
    this.hookState.childIndex = 0;

    return childrenAST
}

function processComponentArgs(arg1, arg2) {
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

function Picker({ args }) {
    const [label, selection, children] = args;

    const setFunction = selection[1] ?? (() => { });

    const id = this.currentPathId('Picker');
    const environmentId = this.storeEnvironment(id);
    const setFunctionId = this.storeFunction(setFunction, id);
    const dataId = this.storeData(selection[0], id);

    const childrenAST = processChildren.bind(this)(children ?? []);

    return {
        props: { label, selection, currentValueId: dataId, setterId: setFunctionId, environmentId },
        children: childrenAST
    }
    
}

// SwiftUI default padding value in points
const DEFAULT_LENGTH = 8;

function Padding({ args }) {
    const standardizedPadding = normalizePaddingArgs(args);
    return { props: standardizedPadding };
}

Padding.environmentValue = (name, args) => {
    const standardizedPadding = normalizePaddingArgs(args);
    return { key: name, value: standardizedPadding }
};

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

function Resizable({ args, content }) {

    const resizable = args[0];

    if (content && content.type === 'Image') {

        // If the content is a Image component, we need to modify its prop directly
        const imageProps = content.props;
        imageProps.resizable = resizable == false ? false : true ;

        // Return the Image directly
        return { ast: content }

    } else {
        return {
            props: { rawValue: resizable },
            children: content
        }
    }
}

function Opacity({ args, content }) {

    const opacity = args[0];

    if (content && content.type === 'Color') {

        // If the content is a Color component, we need to modify its opacity
        const colorProps = content.props;
        if (colorProps && colorProps.a !== undefined) {
            // If the color already has an alpha value, we can just multiply it
            colorProps.a *= opacity;
        } else {
            // Otherwise, we set the alpha value to the first argument
            colorProps.opacity = colorProps.opacity ? colorProps.opacity * opacity : opacity;
        }

        // Return the Color directly
        return { ast: content }

    } else {

        // If the content is not a Color component, we just return it as is
        // but we can still apply the opacity to the parent element
        return {
            props: { rawValue: opacity },
            children: content
        }
    }
}

function OnHandler({ args , name }) {

    // If arg is a function, store it and return handler id
    // If arg is props, process them and return props
    const processArg = (arg) => {
        if (arg == null) {
            return {}
        }

        // Arg is a handler function
        if (typeof arg === 'function') {

            return { handlerId:  this.storeFunction(arg, this.currentPathId(name)) }

        // Arg is a dictionary of props
        } else if (typeof arg === 'object' && !Array.isArray(arg)) {

            return arg

        } else {
            return {}
        }

    };

    // An 'on' handler can take either one or two arguments.
    // First or second may be a function or an object.
    // Second argument is optional but would be a function if present.
    return {
        props: {
            ...processArg(args[0]),
            ...processArg(args[1])
        },
    }
}

var modifierDefaults = {
    'disabled': true
};


// Add all environment value modifiers that need to be accessible in the environment
var modifiersToAddToEnvironment = [
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
    'environment',
    
    // EnvironmentValues from Environment.tsx
    'displayScale',
    'dynamicTypeSize',
    'locale',
    'layoutDirection',
    'screen',
    'platform'
];

function GenericModifier({ args, name }) {

    var props = args[0] == null ? modifierDefaults[name] : args[0];

    // Handle passing single value
    if (Array.isArray(props) || typeof props != 'object' || (typeof props == 'object' && props.type != null)) {
        if (typeof props == 'function') {
            props = props();
        }
        props = { rawValue: props };
    }

    return { props }
}

GenericModifier.environmentValue = (name, args) => {
    if (!modifiersToAddToEnvironment.includes(name)) {
        return null
    }
    return { key: name, value: args[0] }
};

function AnimationComponent({ args, name }) {
    const typeMap = {
        'Spring' : 'spring',
        'EaseIn' : 'easeIn',
        'EaseOut' : 'easeOut',
        'EaseInOut' : 'easeInOut',
        'Linear' : 'linear',
        'Bouncy' : 'bouncy',
        'Snappy' : 'snappy',
        'InterpolatingSpring' : 'interpolatingSpring',
    };

    console.log('AnimationComponent', name, args);

    const props = {
        type: typeMap[name] ?? 'unknown',
        ...(args[0] ?? {})
    };

    return { props }
}

function AnimationModifier({ args,  name, content }) {

    const value = args[0];
    
    // Add the value directly to the props of the content
    const props = content.props;
    props[name] = value;
    
    // Return the AnimationComponent directly to squash the modifier.
    return { ast: content }
}

const propertyNameMap = {
    'PropertyString'  : 'string',
    'PropertyNumber'  : 'number',
    'PropertyBoolean' : 'boolean',
    'PropertyEnum'    : 'enum',
    'PropertyDate'    : 'date',
    'PropertyArray'   : 'array',
    'PropertyAsset'   : 'asset',
    'PropertyGroup'   : 'group',
    'PropertyContent' : 'content',
    'PropertyComponent': 'component',
    'PropertyComponentList': 'componentList',
    'PropertyChildren' : 'children',
};

function PropertyComponent({ args, name }) {
    const props = args?.[0] || {};

    const result = {
        type: propertyNameMap[name] || 'unknown',
        ...props,
    };
    
    return result;
}

function LayoutGroup({ args, name }) {
    const props = args?.[0] || {};

    const result = {
        ...props,
    };
    
    return result;
}

function ComposerGroup({ args, name }) {
    const props = { };

    const env = this.environment;
    var children = null;

    if (args) {
        if (args[0] && args[1] || (typeof args[0] === 'object' && !Array.isArray(args[0])) || typeof args[0] === 'string') {
            // If the first argument is an object, treat it as props
            if (typeof args[0] === 'object' && !Array.isArray(args[0])) {
                Object.assign(props, args[0]);

            } else if (typeof args[0] === 'string') {
                // Otherwise, treat the first argument as a raw value
                props.rawValue = args[0];
            }

            if (args[1]) {
                children = args[1];
            }

        } else if (args[0]) {
            // If the first argument is an array, treat it as children
            children = args[0] ?? [];
        }
    }

    if (!children) {
        let propName = props.property || props.rawValue || props.group;
        if (propName == 'children') {
            children = env?.content?.children || [];
        } else {
            children = env?.content?.layoutProps?.[props.rawValue ?? props.property] || [];
        }
    }

    const childrenAST = processChildren.bind(this)(children).filter(child => {
        return true
        // const groupName = props.group || props.rawValue;

        // const childGroupName = child?.props?.group;

        // if (!groupName && !childGroupName) {
        //     return true
        // }

        // return (childGroupName === groupName)
    });

    
    const result = {
        props: this.processProps(props),
        children: childrenAST
    };
    
    return result;
}

// Helper: Recursively checks if a node or its children matches the given type
function extractPropsByType(node, typeName) {
    var ast = node;
    if (typeof node === 'function') {
        ast = node();
    }

    if (typeof ast === 'object' && ast !== null) {
        if (ast?.type === typeName && typeof ast.props === 'object') {
            const { children, ...restProps } = ast.props;
            return { ...restProps };
        }

        // Recurse into children if they exist
        const astChildren = ast?.props?.children;
        if (astChildren) {
            const children = Array.isArray(astChildren) ? astChildren : [astChildren];
            for (const child of children) {
                const result = extractPropsByType(child, typeName);
                if (result) return result;
            }
        }
    }
    return null;
}

function FontModifier({ args, content }) {
    const [arg] = args;

    const customProps = extractPropsByType(arg, 'FontCustom');
    
    let options = {};
    if (customProps) {
        options = { custom: customProps, rawValue: arg() };
    } else {
        options = { rawValue: arg };
    }

    return {
        props: options,
        children: content,
    };
}

function EnvironmentValue({ args }) {
    const props = { environmentKey: args[0], value: args[1] };
    return { props }
}

EnvironmentValue.environmentValue = (name, args) => {
    return { key: args[0], value: args[1] }
};

// Normalise .fill modifier and pass into to the component it's applied to as a prop
// fill: { style: ShapeStyle }
function Fill({ args, content }) {

    const style = args[0];

    // If the content is a Color component, we need to modify its opacity
    const shapeProps = content.props;

    // If passing { style: Color('red') } etc , then pass dictionary directly
    if (typeof style === 'object' && style.style != null) {
        shapeProps.fill = this.processProps({ ...style });

    // Otherwise if the value is the style itself e.g. Color('red') or 'red', then setup the fill property
    } else if (typeof style === 'function') {
        shapeProps.fill = this.processProps({ style: style });
    }

    // Return the Color directly
    return { ast: content }
}

// Normalise .stroke modifier and pass into to the component it's applied to as a prop
// stroke: { style: ShapeStyle, lineWidth: number }
function Stroke({ args, content }) {

    const style = args[0];

    // If the content is a Color component, we need to modify its opacity
    const shapeProps = content.props;

    // If passing { style: Color('red') } etc , then pass dictionary directly
    if (typeof style === 'object' && style.style != null) {
        shapeProps.stroke = this.processProps({ ...style });

    // Otherwise if the value is the style itself e.g. Color('red') or 'red', then setup the fill property
    } else if (typeof style === 'function') {
        shapeProps.stroke = this.processProps({ style: style });
    } else if (typeof style === 'number') {
        shapeProps.stroke = { lineWidth: style };
    }
    
    // Return the Color directly
    return { ast: content }
}

function ButtonStyle({ args , name }) {

    // If arg is a function, store it and return handler id
    // If arg is props, process them and return props
    const processArg = (arg) => {
        if (arg == null) {
            return {}
        }

        // Arg is a handler function
        if (typeof arg === 'function' && arg._component) {

            let ast = arg();
            let name = ast.props.name;
            let props = ast.props.props || {};
            
            return { name, props }

        // Arg is a string
        } else if (typeof arg === 'string') {

            return { name: arg, props: {} }

        } else {
            return {}
        }

    };

    // An 'on' handler can take either one or two arguments.
    // First or second may be a function or an object.
    // Second argument is optional but would be a function if present.
    let props = {
        props: {
            ...processArg(args[0])
        },
    };

    return props
}

/**
 * Modifier that supports content as a first or second argument.
 * If two arguments are provided, the first is treated as props and the second as content.
 *
 * Used for modifiers like background and overlay.
 */
function ContentModifier({ args, content }) {

    var modifierContent = null;
    var props = {};
    
    if (args.length == 2) {
        modifierContent = args[1];
        props = args[0];
    } else if (args.length == 1) {
        modifierContent = args[0];
    }

    if (typeof modifierContent == 'function') {
        modifierContent = modifierContent();
    }

    return {
        props: { ...props, content: modifierContent },
    }
}

class VisualEffectBuilder {
    constructor() {
        this.result = {};
    }

    blur(radius) {
        this.result.blur = radius;
        return this;
    }

    opacity(amount) {
        this.result.opacity = amount;
        return this;
    }

    offset({ x, y }) {
        this.result.offset = { x, y };
        return this;
    }

    // supports both scale({x,y,anchor}) and scale(value)
    scale(value) {
        if (typeof value === "object" && value !== null) {
            this.result.scale = value;
        } else {
            this.result.scale = { x: value, y: value };
        }
        return this;
    }

    rotation(value) {
        if (typeof value === "object" && value !== null) {
            let degrees = value.degrees ? value.degrees : value.radians * (180 / Math.PI);
            this.result.rotation = degrees;
            return this;
        } else {
            this.result.rotation = value;
        }
        return this;
    }

    transform(matrix) {
        // Only include keys that are defined (so we don't send undefined values to Swift)
        const { m11, m12, m21, m22, tx, ty } = matrix || {};

        // Build transform object only if there's something meaningful to send
        const hasTransform =
            m11 !== undefined || m12 !== undefined ||
            m21 !== undefined || m22 !== undefined ||
            tx  !== undefined || ty  !== undefined;

        if (hasTransform) {
            this.result.transform = {
                m11: m11 ?? 1,
                m12: m12 ?? 0,
                m21: m21 ?? 0,
                m22: m22 ?? 1,
                tx:  tx  ?? 0,
                ty:  ty  ?? 0,
            };
        }

        return this;
    }

    reset() {
        this.result = {};
        return this;
    }

    build() {
        return { ...this.result };
    }

}

function VisualEffectModifier({ args, name }) {

    // Handler function
    var handler = (geometry) => {
        let builder = new VisualEffectBuilder();
        return args[0](builder, geometry).build();
    };

    if (handler == null) {
        return {
            props: {
                handlerId: null
            }
        }
    } else {
        return {
            props: {
                handlerId: this.storeFunction(handler, this.currentPathId(name))
            }
        }
    }
}

function ForEach({ args }) {

    const [data, callback] = args;

    const expand = this.options.expandForEach;
    const count = Array.isArray(data) ? data.length : 0;

    var ast = null;

    if (expand) {
        const children = data.map((element, index) => {
            this.setForEachElementId(index);
            let result = callback(element, index);
            while (result && result._component) {
                result = result();
            }
            return result
        });
        ast = AST.ForEach(null, null, count, null, children);
    } else {
        const id = this.currentPathId('ForEach');
        const environmentId = this.storeEnvironment(id);
        const functionId = this.storeFunction(callback, id);
        const dataId = this.storeData(data, id);

        ast = AST.ForEach(dataId, functionId, count, environmentId);
    }

    return { ast }
}

function Content({ args }) {

    const id = this.currentPathId('Content');
    const environmentId = this.storeEnvironment(id);

    const contentId = typeof args[0] === 'object' ? args[0]?._content : args[0];

    const props = {
        environmentId,
        id: contentId
    };
    return { props }
}

const getComponentData = (child) => {
    let ast = child();
    let data = findComponentDataInAST(ast);
    return data ?? { name: null, props: {}  }
};

const findComponentDataInAST = (node) => {
    if (!node) return null;

    // Base case: If this node is not one of the excluded types, return its type/name
    if (node.type !== "ModifiedComponent" && node.type !== "DOMIdentifable") {
        // For ComponentCall nodes, prefer props.name (since "type" would just be "ComponentCall")
        if (node.type === "ComponentCall") {
            return {
                name: node.name ?? node.props?.name ?? null,
                props: node.props?.props ?? {}
            }
        } else {
            return {
                name: node.type,
                props: node.props ?? {}
            }
        }
    }

    // Otherwise, explore its children or content recursively
    const children =
        node.props?.children ??
        node.content ??
        node.props?.content ?? // current iOS implementation.
        (node.modifier?.props?.children ?? []);

    if (Array.isArray(children)) {
        for (const child of children) {
            const result = findComponentDataInAST(child);
            if (result) return result;
        }
    } else if (children) {
        return findComponentDataInAST(children);
    }

    // Also look into modifier content if present
    if (Array.isArray(node.content)) {
        for (const child of node.content) {
            const result = findComponentDataInAST(child);
            if (result) return result;
        }
    }

    return null;
};

function useState(initialValue) {
    
    // Sanity check
    if (this.hookState.currentComponent == null) {
        return [initialValue, () => {}]
    }

    // Get current state
    var hooks = this.hookState.currentComponent.hookStorage ?? [];
    const hookIndex = this.hookState.currentComponent.hookIndex;

    //console.log(`useState index ${currentHook} value ${hooks[currentHook]} initialValue ${initialValue}`);
    
    // Initialise hook with initialValue if needed
    hooks[hookIndex] = hooks[hookIndex] == null ? initialValue : hooks[hookIndex];

    const rerenderCallback = this.needsRerender;
    const rendererId = this.rendererId;

    // Create setState callback
    let callback = (value) => {

        //console.log(`useState callback value [${value}]`)

        // Update state
        hooks[hookIndex] = value;

        // Trigger a re-render is required due to state changing
        rerenderCallback(rendererId);
        return value
    };

    return [hooks[this.hookState.currentComponent.hookIndex++], callback]
}

function useAppState(key, defaultValue) {
    const rerenderCallback = this.needsRerender;
    const rendererId = this.rendererId;

    const set = (newValue) => {

        // Update the app state with the new value
        this.updatedAppState(key, newValue, (prevState) => {
            // Check if the value has changed
            if (prevState[key] !== newValue) {
                return { ...prevState, [key]: newValue };
            }
            return prevState;  // No change, return previous state
        }, () => {
            // Trigger a re-render if the state has changed
            rerenderCallback(rendererId);
        });
    };

    return [this.appState[key] ?? defaultValue, set];
}

function useNavigate() {
    return this.navigateCallback
}

function makeComponent (component) {

    // Pass body directly or in dictionary
    let body = component.body ? component.body : component;

    // As the name isnt passed in, generate one from the call order
    const componentIndex = this.hookState.makeComponentIndex++;

    //console.log('registerCallback - makeComponent ', component, componentIndex)

    // Create body function
    let f = (props, children) =>
        this.makeComponent((props, children) => body(props, children), props, children, componentIndex);
    
    f._component = true;

    return f
}

async function getContent(content) {
    // Assumes content prop is passed.
    let contentId = content?._content;

    if (this.getContent == null || contentId == null) {
        return null

    // Call the getContent property assigned to the runtime with the contentId.
    } else {
        return await this.getContent(contentId)
    }
}

/**
 * convertComponentProps
 * ---------------------
 * Recursively traverses a props object and replaces any "component-like" objects
 * (objects with a `componentId` and `name` field) with the result of calling that component.
 *
 * A "component-like" object is expected to look like:
 * {
 *   componentId: string,
 *   name: string,
 *   props: object
 * }
 *
 * The function assumes `this.call(name, 'body', props)` is available for resolving components.
 *
 * Efficiency:
 * - Arrays and objects are only cloned if any of their children change.
 * - Component calls are only made when matching shape is detected.
 * - Fast return for primitive types and unchanged structures.
 *
 * @param props - The input props object to convert.
 * @returns A new props object with all components resolved, or the original if unchanged.
 */
function convertComponentProps(props) {
    if (props == null || typeof props !== 'object') return props;

    const callFn = this.call?.bind(this);
    const makeComponent = this.makeComponent?.bind(this);

    function process(item) {
        // Fast-path array
        if (Array.isArray(item)) {
            let changed = false;
            const len = item.length;
            const result = new Array(len);
            for (let i = 0; i < len; i++) {
                const [val, didChange] = process(item[i]);
                if (didChange) changed = true;
                result[i] = val;
            }
            return [changed ? result : item, changed];
        }

        // Fast-path component call
        if (item && typeof item === 'object') {

            // Check for component-like structure with _type == 'ComponentInstance' and _component
            if (item._component != null && item._type == 'ComponentInstance' && callFn) {

                // Wrap in makeComponent, so the function is called at runtime (rather than parsing of props time)
                // So environment works correctly.
                const result = makeComponent(() => {
                    return callFn(item._component, 'body', item);
                });
                
                return [result, true];
            }

            // Check for component-like structure
            if (item.id != null && item.type && item.props && callFn) {
                const result = callFn(item.type, 'body', item.props);
                return [result, true];
            }

            // Traverse object
            let changed = false;
            let result = null;
            for (const key in item) {
                if (!Object.hasOwn(item, key)) continue;
                const val = item[key];
                const [processed, didChange] = process(val);
                if (didChange) {
                    if (!changed) {
                        changed = true;
                        result = { ...item };  // Lazy copy only when the first change occurs
                    }
                    result[key] = processed;  // Apply the changed value
                }
            }
            return [changed ? result : item, changed];
        }

        // Primitive
        return [item, false];
    }

    return process(props)[0];
}

function withAnimation(arg1, arg2) {
    let [component, callback] = (arg1 != null && arg2 != null) ? [arg1, arg2] : [{}, arg1];

    let options = {};
    if (typeof component === 'function' && component._component) {
        let componentAST = component();
        options = {
            type: componentAST.type,
            ...componentAST.props
        };
        delete options.children;
    } else if (typeof component === 'object') {
        options = component;
    }

    console.log('withAnimation', options);

    let handlerId = this.storeFunction(callback, this.currentPathId('withAnimation'));
    if (this.withAnimation) {
        this.withAnimation(handlerId, options);
    } else {
        console.warn('withAnimation is not supported in this environment');
    }
}

let funcs = {};
funcs.capitalize = (s) => {
    return s.charAt(0).toUpperCase() + s.slice(1)
};
funcs.reverse = (s) => s.split('').reverse().join('');
funcs.contains = (s, substr) => s.includes(substr);
funcs.titleCase = (input) => {
    if (input == undefined) {
        return undefined
    }
    const smallWords = new Set([
        'a', 'an', 'and', 'as', 'at', 'but', 'by', 'for', 'in', 'nor',
        'of', 'on', 'or', 'the', 'to', 'up', 'yet'
    ]);

    const words = input.trim().split(/\s+/);

    return words
        .map((word, i) => {
            const lower = word.toLowerCase();

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
};

/**
 * Built in component names
 */
const componentNames = [
    "AngularGradient",
    "AnyView",
    "AsyncImage",
    "Body",
    "Canvas",
    "Circle",
    "ColorPicker",
    "Content",
    "ContentUnavailableView",
    "ControlGroup",
    "ComposerGroup",
    "ComposerAdd",
    "ComposerChildren",
    "FilterChildren",
    "DrawingCanvas",
    "DatePicker",
    "DisclosureGroup",
    "Divider",
    "EditButton",
    "EllipticalGradient",
    "Ellipse",
    "Capsule",
    "EmptyModifier",
    "EmptyView",
    "Empty",
    "EquatableView",
    "EnvironmentValue",
    "ForEach",
    "Form",
    "FontCustom",
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
    "Model3D",
    "NavigationLink",
    "NavigationSplitView",
    "NavigationStack",
    "NavigationView",
    "NewDocumentButton",
    "PasteButton",
    "Path",
    "PhaseAnimator",
    "Picker",
    "Placeholder",
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
    "Video",
    "WindowVisibilityToggle",
    "ZStack"
];

function SheetModifier({ args, name }) {

    // Assume args[0] contains the props
    const props = args[0] ?? { isPresented: false };

    // Extract isPresented binding. First arg is the getter, second is the setter
    const isPresented = props.isPresented
    const setIsPresented = props.setIsPresented ?? (() => { });

    // Extract onDismiss handler if provided
    const onDismiss = props.onDismiss;

    const content = props.content
    
    // Return AST representation when content handler is called.
    const contentHandler = content ? () => {
        // Execute handler, then AST function.
        return content()();
    } : () => {
        return null;
    };

    return {
        props: {
            // Store isPresented binding handlers
            isPresented: isPresented,
            setIsPresentedHandlerId: setIsPresented ? this.storeFunction(setIsPresented, this.currentPathId(name + '_setPresented')) : null,

            // Store content handler
            contentHandlerId: this.storeFunction(contentHandler, this.currentPathId(name + '_content')),

            // Store onDismiss handler if provided
            dismissHandlerId: onDismiss ? this.storeFunction(onDismiss, this.currentPathId(name + '_dismiss')) : null,
        }
    }
}


class BindJSRuntime {
    constructor(options) {
        this.options = options ?? { expandForEach: false };
        this.reset();
    }

    reset() {
        this.context = {};
        this.components = {};
        this.functionCache = {};
        this.modifierFunctions = {};
        this.callStack = [];
        this.environment = {};
        this.storedEnvironments = {};
        this.storedFunctions = {};
        this.storedData = {};
        this.storedHookStates = {};
        this.hookState = {};
        this.modifierRegistry = { GenericModifier };
        this.componentRegistry = { GenericComponent };

        // Default app state that can be managed by the renderer. Can be overridden by the renderer.
        this.appState = { };

        this.resetState();
        this.registerBuiltInCallbacks();
        this.registerBuiltInComponents();

        this.needsRerender = () => {
            console.log('Needs rerender not implemented');
        };

        // Default open url implementation. Can be overriden
        this.onOpenURL = (url, resultCallback) => {
            console.log('onOpenURL', url);
            window.open(url, '_blank');
            if (resultCallback) {
                resultCallback(true);
            }
        };

        // Callback to update the app state.
        // Renderers will want to override this to know when the app state has changed
        // and to update the appropriate storage.
        this.onUpdateAppState = (key, value, state) => {
            // Default implementation.
            this.appState[key] = value;
        };

        this.navigateCallback = (path, options) => {
            console.log('Navigate not implemented', path, options);
        };

        this.withAnimation = (handlerId) => {
            console.log('With animation not implemented', handlerId);
            // Provide default implementation.
            //
            // this.withAnimation should be overridden by the renderer to wrap the animation in a context
            // that will cause the state change to animate
            let animationBlock = this.restoreFunction(handlerId);
            if (animationBlock) {
                animationBlock();
            }
        };
    }

    willRender() {
        this.hookState.path = [];
        this.hookState.makeComponentIndex = 0;
        this.hookState.childIndex = 0;
        this.hookState.modifierId = null;
        this.hookState.forEachElementId = null;
    }

    resetState() {

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
        };
    }

    resetStorage() {
        this.storedEnvironments = {};
        this.storedFunctions = {};
        this.storedData = {};
        this.storedHookStates = {};
    }
    
    resetCache(componentName) {
        this.functionCache[componentName] = {};
    }

    registerASTComponents(componentNames) {
        // Construct AST functions for inbuilt components.
        for (const componentName of componentNames) {
            this.#registerBuiltInComponent(componentName);
        }
    }

    registerBuiltInComponents() {

        this.registerASTComponents(componentNames);

        // Register specific handlers for inbuilt components
        this.#registerBuiltInComponent('Color', Color);
        this.#registerBuiltInComponent('Button', Button);
        this.#registerBuiltInComponent('ForEach', ForEach);
        this.#registerBuiltInComponent('Content', Content);
        this.#registerBuiltInComponent('Picker', Picker);

        // Register specific handlers for inbuilt modifiers
        this.#registerBuiltInModifier('padding', Padding);
        this.#registerBuiltInModifier('opacity', Opacity);
        this.#registerBuiltInModifier('font', FontModifier);
        this.#registerBuiltInModifier('fill', Fill);
        this.#registerBuiltInModifier('stroke', Stroke);
        this.#registerBuiltInModifier('buttonStyle', ButtonStyle);
        this.#registerBuiltInModifier('resizable', Resizable);

        this.#registerBuiltInModifier('background', ContentModifier);
        this.#registerBuiltInModifier('overlay', ContentModifier);
        this.#registerBuiltInModifier('visualEffect', VisualEffectModifier);
        this.#registerBuiltInModifier('sheet', SheetModifier);
        
        // Register event handlers
        ['onTapGesture', 'onDragGesture', 'onLongPressGesture', 'onAppear', 'onDisappear'].map(name => this.#registerBuiltInModifier(name, OnHandler));

        // Register animation components
        ['Spring', 'Linear', 'EaseIn', 'EaseOut', 'EaseInOut', 'Bouncy', 'Snappy', 'InterpolatingSpring'].map(name => this.#registerBuiltInComponent(name, AnimationComponent));

        // Register animation modifiers
        ['delay', 'speed', 'repeatCount', 'repeatForever'].map(name => this.#registerBuiltInModifier(name, AnimationModifier));
        
        ['PropertyString', 'PropertyNumber', 'PropertyEnum', 'PropertyBoolean', 'PropertyArray', 'PropertyAsset', 'PropertyContent', 'PropertyComponent', 'PropertyDate', 'PropertyGroup', 'PropertyChildren', 'PropertyComponentList'].map(name => {
            this.#registerHelperComponent(name, PropertyComponent);
        });

        this.#registerBuiltInComponent('ComposerGroup', ComposerGroup);
        this.#registerBuiltInComponent('ComposerChildren', ComposerGroup);

        // Register layout group
        this.#registerHelperComponent('LayoutGroup', LayoutGroup);

        // Regster environment value modiifer
        this.#registerBuiltInModifier('environment', EnvironmentValue);
    }

    /**
     * Register built in callbacks available to components
     * @param {*} environment
     */
    registerBuiltInCallbacks() {

        this.registerCallback('useEnvironment', () => {
            return this.environment
        });

        // Standard library functions
        for (const key in funcs) {
            this.registerCallback(key, funcs[key]);
        }

        
        // useState
        this.registerCallback('useState', useState.bind(this));

        // useState
        this.registerCallback('useAppState', useAppState.bind(this));

        // useNavigate
        this.registerCallback('useNavigate', useNavigate.bind(this));

        // makeComponent
        this.registerCallback('makeComponent', makeComponent.bind(this));

        // getContent
        this.registerCallback('getContent', getContent.bind(this));

        // getComponentData
        this.registerCallback('getComponentData', getComponentData.bind(this));

        // Prevent top in browser from being interpreted as a function
        this.registerCallback('top', () => { });

        // With animation callback
        this.registerCallback('withAnimation', withAnimation.bind(this));
    }
    
    /**
     * Creates a built in component.
     * A callback can be passed to generate the component, or left empty to use the generic handler.
     */
    #registerBuiltInComponent(name, callback) {
        if (callback) {
            this.componentRegistry[name] = callback;
        }

        this.context[name] = (...args) => {
            return this.#makeInBuiltComponent(name, args)
        };
    }

    /**
     * Registers a built in modifier using a callback
     */
    #registerBuiltInModifier(name, callback) {
        this.modifierRegistry[name] = callback;
    }

    #registerHelperComponent(name, callback) {
        this.context[name] = (...args) => callback({ name, args: args });
    }

    /**
     * Register the JS of one or more components
     * @param {*} components
     */
    registerComponents(components, entryPoint = 'body') {
        for (const componentName of Object.keys(components)) {
            this.registerComponent(componentName, components[componentName], entryPoint);
        }
    }

    registerComponent(componentName, content, entryPoint = 'body')  {
        const name = componentName.replace(/\s/g, '');
        this.callStack = [];
        this.functionCache[name] = {};
        this.components[name] = content;

        this.context[name] = (arg1, arg2, ...otherArgs) => {
            const { props, children } = processComponentArgs(arg1, arg2);

            return this.#makeComponent((props, children) => {

               // Call the body of our registered component
               let componentFunction = this.call(name, entryPoint, this.convertComponentProps(props), children, ...otherArgs);

               // It's assumed a component returns an inbuilt component.
               // Run the returned function to generate the ast
               let ast = componentFunction ? componentFunction() : null;

               if (ast && ast._component) {
                    ast = ast();
               }

               // Wrap the component in a directive so the renderer knows what component generated that part of the AST
               let componentAst = AST.Directive('ComponentCall', { name: name, props: props }, [ ast ]);

               // Return
               return componentAst

            }, props, children, name)

        };
    }

     /**
     * Register callback to be made available to the runtime
     * @param {*} callbackName
     * @param {*} callback
     */
    registerCallback(callbackName, callback) {
        this.context[callbackName] = callback;
    }

    /**
     * Open URL handling
     * @param {*} url
     */
    openURLAction(url, resultCallback) {
        if (this.onOpenURL) {
            this.onOpenURL(url, resultCallback);
        } else if (resultCallback) {
            resultCallback(false);
        }
    }

    /**
     * Register initial environment
     * @param {*} environment
     */
    registerEnvironment(environment = {}) {
        this.environment = { openURL: this.openURLAction.bind(this), ...environment };
    }

    /**
     * AppState
     */
    registerAppState(state) {
        this.appState = state;
    }

    updatedAppState(key, value, newState, completionCallback) {
        // Execute the callback to let the renderer know the app state has changed
        this.onUpdateAppState(key, value, newState(this.appState));

        // If the app state has changed, trigger a re-render
        if (completionCallback) {
            completionCallback();
        }
    }

    /**
     * Restores an environment by id
     * @param {*} environmentId
     */
    restoreEnvironment(environmentId) {
        let env = this.storedEnvironments[environmentId];
        if (env) {
            this.environment = env;
        }

        let hookState = this.storedHookStates[environmentId];
        if (hookState) {
            this.hookState.path = [...hookState.path];
        }
    }

    getEnvironment(environmentId) {
        return this.storedEnvironments[environmentId]
    }

    debugEnvironment() {
        console.log('Envionment:');
        console.log(' - Current:', this.environment);
        console.log(' - Stored: ', this.storedEnvironments);
    }

    /**
     * Unregister a component
     * @param {*} componentName
     * @returns
     */
    unregisterComponent(componentName) {
        delete this.components[componentName];
        delete this.functionCache[componentName];
        delete this.context[componentName];
    }

    setRendererId(id) {
        this.rendererId = id;
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

    convertComponentProps(props) {
        return convertComponentProps.bind(this)(props)
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
    
        let func = null;
        if (this.functionCache[componentName] && this.functionCache[componentName][componentEntryPoint]) {
            //console.log(`[cache hit ${componentName}.${componentEntryPoint}]`)
            func = this.functionCache[componentName][componentEntryPoint];
        } else {
            //console.log(`[constructing ${componentName}.${componentEntryPoint}]`)
            func = new Function(`{ ${functionList} }`, `${this.components[componentName]}; return ${componentEntryPoint}`)(this.context);
            this.functionCache[componentName][componentEntryPoint] = func;
        }

        return func(params, children, ...args)
    }

    /**
     * Process the props for a component or a modifier ,expanding functions in arrays or values
     * @param {*} props
     * @returns
     */
    processProps(props) {
        if (props == null || typeof props != 'object') {
            return props
        }
        
        var newProps = {...props};
        Object.keys(newProps).forEach(key => {
            let value = newProps[key];
            
            // Expand functions in arrays
            if (Array.isArray(value)) {
                newProps[key] = value.map(v =>
                    (typeof v === 'function' && v._component) ? v() : v
                );

            // If the value is an object, process its properties recursively
            } else if (typeof value === 'object' && value !== null) {
                newProps[key] = this.processProps(value);

            // Expand functions if value of key
            } else if (typeof value === 'function' && value._component) {
                newProps[key] = newProps[key]();
            }
        });
        return newProps
    }

    /**
     * Generate a unique identifier for the current hook path.
     *
     * @param {string|number} [name] - Optional segment to include in the path ID.
     * @returns {string} A comma-separated identifier
     */
    currentPathId(name) {
        const { path, childIndex } = this.hookState;
        let id = [this.rendererId ?? 0, ...path, name, childIndex].join(',');
        return id
    }

    /**
     * Creates a modifier function
     */
    #makeModifier(name, f) {

        const makeModifier = this.#makeModifier.bind(this);

        return (...args) => {

            const modifierContent = () => {
    
                const executeModifiedContent = (args) => {
                    
                    // Capture the hook state so it can be maintained once the content is executed
                    const capturedHookState = {...this.hookState};

                    // If this modifier is an id, store the name into the hook state so it can be used
                    // for the hook path
                    if (name == 'id') {
                        this.hookState.modifierId = args[0];
                    }

                    // Will be a function to an inbuilt when modifying a custom component
                    let content = f();
                    if (typeof content === 'function') {
                        content = content();
                    }

                    // Reset hook state id
                    this.hookState.modifierId = null;

                    // Restore state
                    this.hookState = {...capturedHookState};

                    return content
                };

                /**
                 * Find modifier that handles the content for this modifier.
                 * GenericModifier is the default if no specific modifier is found.
                 */
                const modifierFunction = this.modifierRegistry[name] ?? this.modifierRegistry['GenericModifier'];
                if (!modifierFunction) {
                    console.warn(`Modifier ${name} not found`);
                    return {}
                }

                // Process args
                const processedArgs = args.map(arg => {
                    if (typeof arg === 'object' && !Array.isArray(arg)) {
                        return this.processProps(arg)
                    } else {
                        return arg
                    }
                });

                // Execute environment function provided by the modifier function if available
                var capturedEnvironment = null;
                if (modifierFunction.environmentValue) {
                    const result = modifierFunction.environmentValue(name, processedArgs, this.environment);

                    // If the modifier function returns a value, store it in the environment.
                    if (result) {
                        capturedEnvironment = {...this.environment};
                        const { key, value } = result;
                        this.environment[key] = value;
                    }
                }

                // Execute content
                const content = executeModifiedContent(processedArgs);
                
                // Restore environment if needed
                if (capturedEnvironment) {
                    this.environment = capturedEnvironment;
                }

                // Execute modifier function
                const { props: modifierProps, ast: modifierAst } = modifierFunction.bind(this)({ args: processedArgs, content: content, name: name });

                /**
                 * Modifier function can return either an AST or a new set of props.
                 */

                // If the modifier function returns an AST, use it directly
                if (modifierAst) {

                    return modifierAst

                // Otherwise, use the props to create a new modifier
                } else {
                    return AST.ModifiedContent(AST.Directive(name, modifierProps, []), content)
                }
                 
            };
            
            return new Proxy(modifierContent, {
                get: function(target, prop, receiver) {
                    if (prop == 'toJSON' || prop == 'type' || prop == 'children' || prop == 'props') {
                        return target[prop]
                    } else {
                        let modifierName = prop;

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

            let { path, modifierId, childIndex, componentHookStore, currentComponent, forEachElementId } = this.hookState;

            // Push on to hook state path
            // Use id if specified otherwise use child index + component name to create a deterministct path to that item.
            var id = null;
            if (modifierId) {
                id = modifierId;
            } else if (forEachElementId) {
                id = forEachElementId;
            } else {
                id = componentName + '_' + childIndex;
            }
            path.push(id);

            // Create path key. This is a unique key consistent across renders
            let hookKey = path.join('.');

            // Get hook storage for this component
            let hookStorage = componentHookStore[hookKey] ?? (componentHookStore[hookKey] = []);

            // Setup component hook state for the component we're about to call
            currentComponent.hookStorage = hookStorage;
            currentComponent.hookIndex = 0;

            // Call the content function
            let r = body(props, children);

            // Reset
            currentComponent.hookStorage = null;
            path.pop();

            return r
        };
        
        f._component = true;

        const makeModifier = this.#makeModifier.bind(this);

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

    storeEnvironment(environmentId) {
        const id = environmentId ?? this.#generateUniqueID();
        if (this.environment) {
            this.storedEnvironments[id] = {...this.environment};
        }
        if (this.hookState) {
            this.storedHookStates[id] = { path: [...this.hookState.path] };
        }
        return id
    }

    restoreFunction(functionId) {
        return this.storedFunctions[functionId]
    }

    storeFunction(f, functionId) {
        const id = functionId ?? this.#generateUniqueID();
        this.storedFunctions[id] = f;
        return id
    }

    restoreData(dataId) {
        return this.storedData[dataId]
    }

    storeData(data, dataId ) {
        const id = dataId ?? this.#generateUniqueID();
        this.storedData[id] = data;
        return id
    }

    setForEachElementId(id) {
        this.hookState.forEachElementId = id;
    }

    /**
    * Creates a built in component
    */
    #makeInBuiltComponent(type, args) {
        
        return this.#makeComponent((...componentArgs) => {

            const handler = this.componentRegistry[type] ?? this.componentRegistry['GenericComponent'];
            const { props, children, ast } = handler.bind(this)({ args: args, name: type });

            /**
             * Component AST
             */
            if (ast) {
                return ast
            } else {
                return AST.Directive(type, {...props}, children ?? [])
            }

        }, args[0], args[1], type)
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
        let f = this.restoreFunction(functionId);
        let result = f(element, index);
        while(result && result._component) {
            result = result();
        }
        return result
    }

}


// MARK: - After the runtime...

// Custom JSON stringify that preserves Infinity, -Infinity, and NaN
function customJSONStringify(value, replacer, space) {
    return JSON.stringify(value, (key, val) => {
        if (val === Infinity) return "Infinity";
        if (val === -Infinity) return "-Infinity";
        if (Number.isNaN(val)) return "NaN";
        return replacer ? replacer(key, val) : val;
    }, space);
}

const runtime = new BindJSRuntime();

Object.assign(this, {
    setComponents: (args) => runtime.registerComponents(args),
    setASTComponents: (components, modifiers) => runtime.registerASTComponents(components, modifiers),
    call: (args) => runtime.call(...args)(),
    callComponent: (args) => runtime.callComponent(...args),
    setEnvironment: (environment) => runtime.registerEnvironment(environment),
    makeComponent: (body, props, children) => runtime.makeComponent(body, props, children),
    restoreEnvironment: (environmentId) => runtime.restoreEnvironment(environmentId),
    restoreFunction: (functionId) => runtime.restoreFunction(functionId),
    setForEachElementId: (id) => runtime.setForEachElementId(id),
    callForEachFunction: (functionId, element, index) => runtime.callForEachFunction(functionId, element, index),
    restoreForEachData: (dataId) => runtime.restoreData(dataId),
    restorePickerValue: (dataId) => runtime.restoreData(dataId),
    restoreEventHandler: (handlerId) => runtime.restoreEventHandler(handlerId),
    callEventHandler: (handlerId, ...args) => {
        const handler = runtime.storedFunctions[handlerId]
        if (handler) {
            return handler(...args)
        }
        return null
    },
    willRender: () => runtime.willRender(),
    debug: () => console.log(customJSONStringify(runtime.components)),
    reset: () => runtime.reset(),
    setAppState: (state) => runtime.registerAppState(state),
    updatedAppState: (key, value, completionCallback) => runtime.updatedAppState(key, value, (s) => ({ ...s, [key]: value }), completionCallback),
    setOnOpenURL: (callback) => runtime.onOpenURL = callback
});

