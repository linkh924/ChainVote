const fs = require('fs');

const fileName = 'oracle.js';

try {
    let script = fs.readFileSync(fileName, 'utf8');

    script = script.replace(/\/\/.*$/gm, '');
    script = script.replace(/\/\*[\s\S]*?\*\//g, '');

    const minified = script
        .replace(/\r?\n|\r/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();

    console.log("================ 壓縮完成 (複製下方字串) ================");
    console.log(JSON.stringify(minified));
    console.log("======================================================");
} catch (err) {
    console.error("錯誤：找不到 oracle.js 檔案");
}