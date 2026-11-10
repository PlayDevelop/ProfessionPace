// Kör: node tests/run-tests.cjs. Verktygsberoenden hämtas enbart till tests/.tools.
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const root = path.resolve(__dirname, '.tools');
async function install(name, version) {
  const dest = path.join(root, 'node_modules', name);
  if (fs.existsSync(path.join(dest, 'package.json'))) return;
  const meta = await (await fetch(`https://registry.npmjs.org/${name}/${version}`)).json();
  if (!meta.dist?.tarball) throw Error(`Kan inte hämta ${name}`);
  const response = await fetch(meta.dist.tarball);
  if (!response.ok) throw Error(`Hämtning misslyckades: ${name}`);
  fs.mkdirSync(dest, {recursive:true});
  const archive = path.join(root, `${name}.tgz`);
  fs.writeFileSync(archive, Buffer.from(await response.arrayBuffer()));
  execFileSync('tar', ['-xzf', archive, '-C', dest, '--strip-components=1']);
}
(async () => {
  for (const [name, version] of [['fengari','0.1.5'], ['sprintf-js','1.1.3'],
    ['readline-sync','1.4.10'], ['tmp','0.0.33'], ['os-tmpdir','1.0.2']]) await install(name, version);
  const {lua,lauxlib,lualib,to_luastring,to_jsstring} = require(path.join(root,'node_modules/fengari'));
  const state = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(state);
  for (const [name, file] of [['logicSource','ProfessionPace/Logic.lua'],
    ['addonSource','ProfessionPace/ProfessionPace.lua']]) {
    lua.lua_pushstring(state,to_luastring(fs.readFileSync(path.resolve(__dirname,'..',file),'utf8')));
    lua.lua_setglobal(state,to_luastring(name));
  }
  const tests = fs.readFileSync(path.join(__dirname,'test.lua'),'utf8');
  const result = lauxlib.luaL_dostring(state,to_luastring(tests));
  if (result !== lua.LUA_OK) throw Error(to_jsstring(lua.lua_tostring(state,-1)));
})().catch(error => {console.error(error); process.exitCode=1;});
