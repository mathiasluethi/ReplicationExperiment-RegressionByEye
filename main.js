let slider = document.getElementById("myRange");
let output = document.getElementById("demo");
let canvas = document.getElementById("myCanvas");
ctxb = canvas.getContext("2d");
output.innerHTML = slider.value;
let data;
let inPracticeMode = false;
let taskIndex = 0;
let task;
let background;
let line;
let participant = '';
let graphtype;
let taskCount;
let headers;

function selectParticipant() {
  participantDropdown.hidden = true;
  practice_screen.hidden = false;
  participant = participantDropdown.value;
  console.log('participant: ', participant);
}

function startPractice() {
  inPracticeMode = true;
  main_experiment.hidden = false;
  practice_screen.hidden = true;
  setupPractice();
}

function startMainWelcome() {
  main_welcome_screen.hidden = false;
  main_experiment.hidden = true;
}

function startMain(){
  main_welcome_screen.hidden = true;
  main_experiment.hidden = false;
  setupExperiment();
}

// Setup Practice
async function setupPractice() {
  taskIndex = 0;
  let d = loadPracticeData();
  data = await d;
  newGraph();
}

// Setup experiment
async function setupExperiment() {
  taskIndex = 0;
  let d = loadData();
  data = await d;
  newGraph();
}

// Draws a new graph with background image, resets the slider
function newGraph() {
  task = data[taskIndex];
  console.log(task);
  line = task.graphtype;
  slider.value = 0;
  output.innerHTML = 0;
  loadImage(task);
}

// Load in the csv file and convert it to an object
async function loadPracticeData() {
  let data = $.get("./data/csvs/Practice.csv").then(function(csv){
    var lines = csv.split("\n");
    var result = [];
    taskCount = lines.length - 1;
    console.log(taskCount);
    headers = lines[0].split(",");
    console.log(headers);
    for(var i=1; i<lines.length; i++){
      var obj = {};
      var currentline = lines[i].split(",");
      for(var j=0; j<headers.length; j++){
        obj[headers[j]] = currentline[j];
      }
      result.push(obj);
    }
    return result;
  });
  return await data;
}

// Load in the csv file and convert it to an object
async function loadData() {
  let data = $.get("./data/csvs/" + participant + ".csv").then(function(csv){
    var lines = csv.split("\n");
    var result = [];
    taskCount = lines.length - 1;
    console.log(taskCount);
    headers = lines[0].split(",");
    console.log(headers);
    for(var i=1; i<lines.length; i++){
      var obj = {};
      var currentline = lines[i].split(",");
      for(var j=0; j<headers.length; j++){
        obj[headers[j]] = currentline[j];
      }
      result.push(obj);
    }
    return result;
  });
  return await data;
}


// Save experiment data to csv
function saveData() {
  var array = typeof data != 'object' ? JSON.parse(data) : data;
  var str = headers + '\r\n';
  for (var i = 0; i < array.length; i++) {
    var line = '';
    for (var index in array[i]) {
      if (line != '') line += ','
      line += array[i][index];
    }
    str += line + '\n';
  }
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(str);
  hiddenElement.target = '_blank';
  hiddenElement.download = participant + '.csv';
  hiddenElement.click();
  return str;
}

// Load images
function loadImage(task) {
  background = new Image();
  background.src = task.src;
  // Make sure the image is loaded first otherwise nothing will draw.
  background.onload = function(){
    ctxb.drawImage(background, 0 , 0, 300, 525);
  }
}

// Update the current slider value (each time you drag the slider handle)
slider.oninput = function() {
  sliderValue = this.value;
  output.innerHTML = sliderValue;
  graphtype = line;
  drawRegression(sliderValue);
  nextButton.disabled = false;
}

// Change the data based on input and move to the new task
function next() {
  if (inPracticeMode == true) {
    if (taskIndex >= taskCount-1) {
      inPracticeMode = false;
      startMainWelcome();
    } else {
      taskIndex = taskIndex + 1;
      newGraph();
    }
  } else {
    data[taskIndex].answer = slider.value;
    nextButton.disabled = true;

    if (taskIndex >= taskCount-1) {
      finishScreen();
    } else {
      taskIndex = taskIndex + 1;
      newGraph();
    }
  }
}

// Last screen, saving
function finishScreen(){
  main_experiment.hidden=true;
  goodbyeScreen.hidden = false;
}
function screenSaveData(){
  let csvData = saveData();
}

// Change the data based on input and move to the new task
function previous() {
  if (taskIndex >= 1) {
    data[taskIndex].answer = slider.value;
    taskIndex = taskIndex - 1;
    nextButton.disabled = true;
    newGraph();
  } else {
    alert("You can't move back. This is the first task.")
  }
}

// draw the regression
function drawRegression(sliderValue) {
  let ctx = canvas.getContext("2d");
  ctx.lineWidth = 3;
  ctx.strokeStyle = 'blue';
  ctx.clearRect(0, 0, 300, 525);
  ctxb.drawImage(background, 0, 0, 300, 525);
  let resolution = 100;
  let X1, X2, Y1, Y2;
  ctx.beginPath();
  for (var i = 0; i < resolution; i++) {
    X1 = scale(i, 0, resolution, 0, 1);
    X2 = scale(i + 1, 0, resolution, 0, 1);
    if (graphtype === "line") {
      Y1 = 0.5 + (X1 - 0.5) * sliderValue;
      Y2 = 0.5 + (X2 - 0.5) * sliderValue;
    } else if (graphtype === "trig") {
      Y1 = 0.5 - 0.5 * Math.cos(X1 * Math.PI) * sliderValue;
      Y2 = 0.5 - 0.5 * Math.cos(X2 * Math.PI) * sliderValue;
    } else if (graphtype === "quad") {
      Y1 = 0.5 + sliderValue * Math.pow(X1,2) - 0.5 * sliderValue;
      Y2 = 0.5 + sliderValue * Math.pow(X2,2) - 0.5 * sliderValue;
    }
    ctx.moveTo(toScreenX(i/resolution),toScreenY(Y1));
    ctx.lineTo(toScreenX((i+1)/resolution),toScreenY(Y2));

  }
  ctx.stroke();
}

function toScreenY(dataY) {
  return scale(dataY, 0, 1, 525 - (2 * 5)- 112.5, (2 * 5) + 112.5);
}
function toScreenX(dataX) {
  return scale(dataX, 0, 1, (2*5), 300-(2*5));
}
const scale = (num, in_min, in_max, out_min, out_max) => {
  return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
