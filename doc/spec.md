# Ctrl definition

original definition ( used in loading.io )

    {
      a: name: '...', type: '...', default: '...', priority: 0.5, tab: '...'
      ..
    }

proposed improving:

    {
      tab-a: # group ctrls in one named tab
        name: '...', type: 'group', priority: 0.5
        ctrl: {}
      tab-b:
        name: '...', type: 'group',
        collapsed: true # default show / not show
        priority: undefined # ctrls without priorities are sorted by name, placed after ctrls with priority
        ctrl:
          inp-a: { name: '...', type: '...', default: '...', priority: 0.5 }
      # stray ctrl can still have tab. overwrite when conflict ( make extension easier )
      inp-b: { name: '...', type: '...', default: '...', priority: 0.5, tab: 'tab-a' }
    }
