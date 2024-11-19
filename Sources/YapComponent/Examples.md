// @description Creates components from low-level AST
AST.Directive(name: string, props: object, children?: any[])
AST.ModifiedContent(modifier: object, component: object | object[])
AST.ForEach(dataId: string, functionId: string, count: number)

// @description Creates reusable components
makeComponent((props: any, children: Component[]) => Component)

// @description Accesses environment values
useEnvironment(): {
  displayScale: number,
  colorScheme: "light" | "dark",
  colorSchemeContrast: string,
  dynamicTypeSize: string,
  scenePhase: string,
  accessibilityReduceMotion: boolean,
  accessibilityReduceTransparency: boolean,
  accessibilityDifferentiateWithoutColor: boolean,
  accessibilityInvertColors: boolean,
  locale: string,
  layoutDirection: string
}

NOTE: If you use any modifier (including arbitrary ones), it will place its name as a key and its args as the value in the environment.

## Components

// @description Text views
// @example
Text({ value: "Hello" })
Text({ value: "Multi\nLine\nText" })
// @props {
//   value: string
// }
// @modifiers [
//   font, bold, italic, foregroundStyle, tracking, kerning,
//   lineLimit, multilineTextAlignment
// ]

// @description Button controls
// @example
Button({ action: "handlePress" }, [
  Text({ value: "Submit" })
])
Button({ action: "delete" }, [
  HStack({ spacing: 8 }, [
    Image({ systemName: "trash" }),
    Text({ value: "Delete" })
  ])
])
// @props {
//   action: string
//   label?: AST  // Alternative to children
// }
// @modifiers [
//   buttonStyle, disabled, padding
// ]

// @description Toggle switches
// @example
Toggle({ isOn: true }, [
  Text({ value: "Enable" })
])
// @props {
//   isOn: boolean
//   label?: AST
// }
// @modifiers [
//   toggleStyle
// ]

// @description Progress indicators
// @example
ProgressView()
ProgressView({ value: 0.7, total: 1.0 })
// @props {
//   value?: number
//   total?: number
// }
// @modifiers [
//   progressViewStyle
// ]

// @description Vertical stack layout
// @example
VStack({ spacing: 16 }, [
  Text({ value: "Title" }),
  Text({ value: "Description" })
])
// @props {
//   spacing?: number
//   alignment?: "leading" | "center" | "trailing"
// }

// @description Horizontal stack layout
// @example
HStack({ spacing: 8 }, [
  Image({ systemName: "star" }),
  Text({ value: "Favorite" })
])
// @props {
//   spacing?: number
//   alignment?: "top" | "center" | "bottom" | "firstTextBaseline" | "lastTextBaseline"
// }

// @description Depth stack layout
// @example
ZStack({ alignment: "center" }, [
  Circle({})
    .foregroundStyle(Color({ value: "blue" })),
  Text({ value: "1" })
    .foregroundStyle(Color({ value: "white" }))
])
// @props {
//   alignment?: "center" | "leading" | "trailing" | "top" | "bottom" | 
//              "topLeading" | "topTrailing" | "bottomLeading" | "bottomTrailing"
// }

// @description Lazy loading stacks
// @example
LazyHStack({ spacing: 16 }, [ /* many items */ ])
LazyVStack({ spacing: 16 }, [ /* many items */ ])
// @props - Same as HStack/VStack

// @description Scrollable container
// @example
ScrollView({ axis: "vertical", showsIndicators: true }, [
  VStack({}, [ /* content */ ])
])
// @props {
//   axis?: "vertical" | "horizontal" | "both"
//   showsIndicators?: boolean
// }

// @description List container
// @example
List({}, [
  Text({ value: "Item 1" }),
  Text({ value: "Item 2" })
])
// @props {}

// @description Shapes
// @example
Circle({})
Rectangle({})
RoundedRectangle({ cornerRadius: 8 })
Capsule({})
Ellipse({})
// @props {
//   cornerRadius?: number  // RoundedRectangle only
// }

// @description Colors
// @example
Color({ value: "red" })
Color({ red: 1, green: 0, blue: 0, alpha: 0.5 })
// @props {
//   value?: "clear" | "red" | "orange" | "yellow" | "green" | "mint" | "teal" | 
//          "cyan" | "blue" | "indigo" | "purple" | "pink" | "brown" | "black" |
//          "white" | "gray" | "primary" | "secondary" | "accentColor" | "background"
//   red?: number   // 0-1
//   green?: number // 0-1
//   blue?: number  // 0-1
//   alpha?: number // 0-1
// }

// @description Gradients
// @example
LinearGradient({
  colors: [Color({ value: "blue" }), Color({ value: "purple" })],
  startPoint: "top",
  endPoint: "bottom"
})
// @props {
//   colors: Color[]
//   startPoint?: "center" | "zero" | "top" | "bottom" | "leading" | "trailing" | 
//               "topLeading" | "topTrailing" | "bottomLeading" | "bottomTrailing"
//   endPoint?: string  // Same as startPoint
// }

// @description Material effects
// @example
Material({ value: "regular" })
// @props {
//   value: "regular" | "ultraThin" | "thin" | "thick" | "ultraThick"
// }

// @description Images
// @example
Image({ systemName: "star.fill" })
Image({ url: "https://example.com/image.jpg" })
// @props {
//   systemName?: string  // SF Symbols name
//   url?: string        // Image URL
//   name?: string       // Asset name
// }

// @description Dynamic lists
// @example
ForEach(items, (item, index) => 
  HStack({}, [
    Text({ value: item.title }),
    Spacer(),
    Text({ value: item.subtitle })
  ])
)

// @description Flexible spacing
// @example
Spacer()
Spacer({ minLength: 44 })
// @props {
//   minLength?: number
// }

// @description Divider line
// @example
Divider()

## Modifiers

// @description Layout modifiers
.frame({  // Fixed frame
  width?: number,
  height?: number,
  alignment?: string
})
.frame({  // Flexible frame
  minWidth?: number,
  idealWidth?: number,
  maxWidth?: number,
  minHeight?: number,
  idealHeight?: number,
  maxHeight?: number,
  alignment?: string
})
.padding(number)
.padding({
  top?: number,
  leading?: number,
  bottom?: number,
  trailing?: number
})
.offset({ x?: number, y?: number })
.offset(number)  // Both x and y
.position({ x: number, y: number })
.aspectRatio({
  aspectRatio?: number,
  contentMode?: "fit" | "fill"
})
.zIndex(number)

// @description Visual modifiers
.blur({ radius: number })
.blur(number)
.shadow({
  color?: Color,
  radius: number,
  x?: number,
  y?: number
})
.cornerRadius(number)
.border({
  style: Color | LinearGradient | Material,
  width?: number
})
.border(Color | LinearGradient | Material)
.opacity(number)  // 0-1
.scaleEffect({ x?: number, y?: number })
.scaleEffect(number)
.scaledToFit()
.scaledToFill()
.rotationEffect({
  angle: number,
  anchor?: string
})

// @description Content modifiers
.background(Component)
.overlay(Component)
.mask(Component)
.compositingGroup()
.foregroundStyle(Color | LinearGradient | Material)

// @description Text modifiers
.font(number)  // Size
.font("body" | "callout" | "caption" | "footnote" | "headline" | 
      "largeTitle" | "subheadline" | "title" | "title2" | "title3")
.fontWeight("ultraLight" | "thin" | "light" | "regular" | "medium" | 
            "semibold" | "bold" | "heavy" | "black")
.fontDesign("default" | "serif" | "rounded" | "monospaced")
.bold()
.bold(boolean)
.italic()
.italic(boolean)
.tracking(number)
.kerning(number)
.lineLimit(number)
.multilineTextAlignment("leading" | "center" | "trailing")

// @description Style modifiers
.buttonStyle("plain" | "bordered" | "borderedProminent" | "borderless" | 
             "link" | string)
.toggleStyle("checkbox" | "switch" | "button" | "default" | string)
.labelStyle("iconOnly" | "titleAndIcon" | "titleOnly" | "automatic" | string)
.progressViewStyle("circular" | "linear" | string)

// @description State modifiers
.disabled(boolean)
.hidden(boolean)

// @description Layout behavior
.ignoresSafeArea("all" | "top" | "bottom" | "leading" | "trailing" | 
                 "horizontal" | "vertical")

// @description Accessibility
.accessibilityLabel(string)

## Example Component

```javascript
const Card = (props, children) => {
  const env = useEnvironment()
  
  return VStack({ spacing: 16 }, [
    HStack({ spacing: 8 }, [
      Image({ systemName: props.icon })
        .font(24)
        .foregroundStyle(Color({ value: props.color })),
      Text({ value: props.title })
        .font("headline")
    ]),
    ...children
  ])
  .padding(16)
  .background(
    RoundedRectangle({ cornerRadius: 12 })
      .foregroundStyle(
        Color({ value: env.colorScheme === "dark" ? "gray" : "white" })
      )
  )
  .shadow({ radius: 4 })
}

// ALWAYS INCLUDE CONST BODY
const body = () => Card({ 
  icon: "star.fill",
  color: "blue", 
  title: "Featured"
}, [
  Text({ value: "Additional content" })
])
