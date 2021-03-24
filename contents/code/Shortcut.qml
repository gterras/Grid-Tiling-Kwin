import QtQuick 2.0

Item {
  readonly property string prefix: 'Grid-Tiling: '

  function register(name, shortcut, method) {
    KWin.registerShortcut(prefix + name, prefix + name, shortcut, method);
  }

  function togglers() {
    register('Tile/Float', 'Meta+Ctrl+F', () => {
      if (manager.toggle(workspace.activeClient))
        layout.render();
    });

    register('Toggle Tile', 'Meta+Ctrl+T', () => {
      config.tile = !config.tile;
    });

    register('Toggle Gap', 'Meta+Ctrl+G', () => {
      config.gapShow = !config.gapShow;
      layout.render();
    });

    register('Toggle Border', 'Meta+Ctrl+B', () => {
      config.border = !config.border;
      layout.render();
    });

    register('Toggle Minimize Desktop', 'Meta+Ctrl+M', () => {
      const screen = manager.getActiveScreen();
      if (screen) {
        const minimize = screen.nclients() - screen.nminimizedClients() > 1;
        for (const line of screen.lines) {
          for (const client of line.clients)
            client.minimized = minimize;
        }
      }
    });
  }

  function dividers() {
    for (const [text, shortcut, amount] of [
      ['Increase Step', '', config.divider.step],
      ['Decrease Step', '', -config.divider.step],
      ['Increase Max', 'Meta++', config.divider.bound],
      ['Decrease Max', 'Meta+_', -config.divider.bound]
      ]) {
      register(text, shortcut, () => {
        const client = workspace.activeClient;
        const screen = manager.getScreen(client);
        if (screen) {
          screen.lines[client.lineIndex].changeDivider(amount, client.clientIndex);
          screen.changeDivider(amount, client.lineIndex);
          screen.render(client.screenIndex, client.desktopIndex, client.activityId);
        }
      });
  }
}

function dimensions() {
  for (const [text, shortcut, amount] of [
    ['Decrease Width', 'Meta+Ctrl+Alt+H', -config.divider.step],
    ['Increase Width', 'Meta+Ctrl+Alt+L', config.divider.step],
    ['Decrease Height', 'Meta+Ctrl+Alt+J', -config.divider.step],
    ['Increase Height', 'Meta+Ctrl+Alt+K', config.divider.step],
    ]) {
    register(text, shortcut, () => {
      const client = workspace.activeClient;
      const screen = manager.getScreen(client);
      if (screen) {
        if (text.toLowerCase().includes('width'))
          screen.changeDivider(amount, client.lineIndex);
        if (text.toLowerCase().includes('height'))
          screen.lines[client.lineIndex].changeDivider(amount, client.clientIndex);
        screen.render(client.screenIndex, client.desktopIndex, client.activityId);
      }
    });
}
}

function focus() {
  for (const [text, shortcut, amount] of [
    ['Focus Right', 'Meta+Ctrl+W', -1],
    // ['Increase Width', 'Meta+Ctrl+Alt+L', config.divider.step],
    // ['Decrease Height', 'Meta+Ctrl+Alt+J', -config.divider.step],
    // ['Increase Height', 'Meta+Ctrl+Alt+K', config.divider.step],
    ]) {

    register(text, shortcut, () => {
      const activeClient = workspace.activeClient;
      const clientIndex = activeClient.clientIndex;
      const clients = workspace.clientList()
        //console.log(Object.values(clients))
      const filteredClients = Object.values(workspace.clientList()).filter(c =>  !manager.ignored(c))
      const t = filteredClients.map(c => c.geometry.x).sort((a, b) => a - b).filter(num => num > activeClient.geometry.x)[0]

           if (!t) 
          return;


        //numArray.sort((a, b) => b - a); // descending
console.log('lul',t)
        //const closest = Math.min(...t.filter(num => num > activeClient.geometry.x));
        //console.log('lul3', ...t.filter(num => num > activeClient.geometry.x))

    // if (!closest) 
         // return;
        const ok = filteredClients.find(c => c.geometry.x == t)
console.log('lul4')
        

        if (!ok) 
          return;
console.log('lul5')

        // let test = 0;
        // for (const c of Object.values(workspace.clientList())) {
        //   if (!manager.ignored(c)){
        //      test++
        //   }
        // }
        // const clientAmount = clients.length
        // console.log(clientIndex,clientAmount, filteredClients,t)
        //console.log(clientAmount,clientIndex)
        //if (clientIndex < clientAmount )
          workspace.activeClient = ok
console.log('lul6')

      });
}
}

function moveSwap() {
  for (const [text, shortcut, amount] of [
    ['Swap Up', 'Meta+Ctrl+Up', -1],
    ['Swap Down', 'Meta+Ctrl+Down', 1]
    ]) {
    register(text, shortcut, () => {
      const client = workspace.activeClient;
      const screen = manager.getScreen(client);
      if (screen && screen.lines[client.lineIndex].swapClient(amount, client.clientIndex))
        screen.render(client.screenIndex, client.desktopIndex, client.activityId);
    });
}

for (const [text, shortcut, amount] of [
  ['Move/Swap Left', 'Meta+Ctrl+Left', -1],
  ['Move/Swap Right', 'Meta+Ctrl+Right', 1]
  ]) {
  register(text, shortcut, () => {
    const client = workspace.activeClient;
        //console.log(JSON.stringify(client));
        //console.log(Object.values(workspace.clientList()))
        //console.log(client.resourceClass)
        const screen = manager.getScreen(client);
        if (screen && (screen.moveClient(amount, client.clientIndex, client.lineIndex, client.screenIndex, client.desktopIndex) || screen.swapLine(amount, client.lineIndex)))
          screen.render(client.screenIndex, client.desktopIndex, client.activityId);
      });
}

for (const [text, shortcut, amount] of [
  ['Move Next Desktop/Screen', 'Meta+End', 1],
  ['Move Previous Desktop/Screen', 'Meta+Home', -1]
  ]) {
  register(text, shortcut, () => {
    const client = workspace.activeClient;
    if (!client || manager.ignored(client))
      return;
    const last = workspace.numScreens - 1;
    const i = client.screen + amount;
    if (i >= 0 && i < last) {
      workspace.sendClientToScreen(client, i);
    } else if (i < 0) {
      workspace.sendClientToScreen(client, last);
      client.desktop = client.desktop > 1 ? client.desktop - 1 : client.desktop = workspace.desktops;
    } else {
      workspace.sendClientToScreen(client, 0);
      client.desktop = client.desktop < workspace.desktops ? client.desktop + 1 : 1;
    }

    delay.set(config.delay, () => {
      workspace.currentDesktop = client.desktop;
    });
  })
}
}

function init() {
  togglers();
  dividers();
  focus();
  dimensions();
  moveSwap();

  register('Close Desktop', 'Meta+Q', () => {
    for (const client of Object.values(workspace.clientList())) {
      if (client && client.screen === workspace.activeScreen && client.desktop === workspace.currentDesktop && (client.activities.length === 0 || client.activities.includes(workspace.currentActivity)))
        client.closeWindow();
    }
  });

  register('Refresh', 'Meta+R', () => {
    manager.init();
    layout.render();
  });
}
}
