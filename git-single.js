#!/usr/bin/env node

const fs = require("fs");
const path = require("path")

async function downloadFile(url,filename,dir) {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Download failed: ${response.status}`);
  }
  const buffer = Buffer.from(await response.arrayBuffer());

  if (dir) {
    fs.mkdirSync(dir,({recursive:true}))
    fs.writeFileSync(path.join(dir,filename), buffer);
  } else {
    fs.writeFileSync(filename, buffer);
  }

  console.log(`Downloaded: ${filename}`);
}


async function getDir(url) {

    const ul = new URL(url);

    const parts = ul.pathname.split("/").filter(Boolean);

    const username = parts[0];
    const repo = parts[1];
    const branch = parts[3];
    const path = parts[4];
   
        

    const respose = await fetch(url)
    const text = await respose.text();

    const regex = new RegExp(`\\/${path}\\/[^\\"?#]+`, "g");

    const matches = text.match(regex).map(match => match.replace(`/${path}/`, ""));
   

    const removedup = [... new Set(matches)]

    for (const file of removedup) {
        downloadFile(`https://raw.githubusercontent.com/${username}/${repo}/refs/heads/${branch}/${path}/${file}`,`${file}`,`${path}`)
    }

}



async function getFile(url) {
    const ul = new URL(url);

    const parts = ul.pathname.split("/").filter(Boolean);

    
    const username = parts[0];
    const repo = parts[1];
    const branch = parts[3];

    // little bit conflix here cause 
    // const path = parts[4]
    // const file = parts[5];

    // if use downlaod from the file from the main lenth is 5 
    if (parts.length === 5 ) {
         downloadFile(`https://raw.githubusercontent.com/${username}/${repo}/refs/heads/${branch}/${parts[4]}`,`${parts[4]}`)

    
    } else {
         downloadFile(`https://raw.githubusercontent.com/${username}/${repo}/refs/heads/${branch}/${parts[4]}/${parts[5]}`,`${parts[5]}`)
    
    }
    


    
}


const comand = process.argv[2]
if (comand.match("tree")) {
    getDir(comand)
}else if (comand.match("blob")) {
    getFile(comand)
}else {
    console.log('either you are puting wrong url full repo url')
}



