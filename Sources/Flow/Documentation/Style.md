//
//  Style.md
//  
//
//  Created by Zhu Shengqi on 2019/12/6.
//

# Design spec

## Class responsibilities
1. StyleSemanticCategory: used for tagging stylable classes for different semantic meanings, e.g. "Content Header", "Main title".
2. StyleSelector: similar to CSS selector, used for identify an stylable object in UI hierarchy.
3. StyleProperty: a record which can be used to modify a stylable object using keyPath and value.
4. StyleRule: like CSS rule, organize different style properties under same style selector.

Style rule can only be created in a style scope container (which binds to a stylable object). 
