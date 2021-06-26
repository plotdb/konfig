config =
  general:
    type: \group
    text:
      type: \scope
      size: type: \number
      family: type: \font
  advanced:
    type: \group

dom = """
<div>
  <div class="
  </div>
"""

view =
  handler:
    group:
      list: ({ctx}) -> [{k,v} for k,v of ctx].filter -> it.v.type == \group
      view: view
    scope:
      list: ({ctx}) -> [{k,v} for k,v of ctx].filter -> it.v.type == \scope
      view: view
    entry:
      list: ({ctx}) -> [{k,v} for k,v of ctx].filter -> !(it.v.type in <[group scope]>)
