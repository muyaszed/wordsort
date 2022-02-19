import '../models/box.dart';

List<String> checkSolution(List<Box> updatedBox, solution) {
  //check horizontal
  var row1Sort = updatedBox.where((box) => box.tile.y == 1).toList();
  row1Sort.sort(((a, b) => a.tile.x.compareTo(b.tile.x)));
  var row2Sort = updatedBox.where((box) => box.tile.y == 2).toList();
  row2Sort.sort(((a, b) => a.tile.x.compareTo(b.tile.x)));
  var row3Sort = updatedBox.where((box) => box.tile.y == 3).toList();
  row3Sort.sort(((a, b) => a.tile.x.compareTo(b.tile.x)));
  var row4Sort = updatedBox.where((box) => box.tile.y == 4).toList();
  row4Sort.sort(((a, b) => a.tile.x.compareTo(b.tile.x)));
  var row5Sort = updatedBox.where((box) => box.tile.y == 5).toList();
  row5Sort.sort(((a, b) => a.tile.x.compareTo(b.tile.x)));

  // print(row1Sort.map((e) => e.letter));
  // print(row2Sort.map((e) => e.letter));
  // print(row3Sort.map((e) => e.letter));
  // print(row4Sort.map((e) => e.letter));
  // print(row5Sort.map((e) => e.letter));

  var row1 = row1Sort.map((row) => row.letter != '' ? row.letter : '#').join();
  var row2 = row2Sort.map((row) => row.letter != '' ? row.letter : '#').join();
  var row3 = row3Sort.map((row) => row.letter != '' ? row.letter : '#').join();
  var row4 = row4Sort.map((row) => row.letter != '' ? row.letter : '#').join();
  var row5 = row5Sort.map((row) => row.letter != '' ? row.letter : '#').join();

  for (var answer in [row1, row2, row3, row4, row5]) {
    var epmtyIndex = answer.indexOf("#");
    if (epmtyIndex == 4 || epmtyIndex == 0) {
      answer = answer.split("#").join();
    }
    solution.removeWhere((solution) => solution == answer);
  }

  //check Horizontal reverse
  var hReverse1 = row1.split('').reversed.join();
  var hReverse2 = row2.split('').reversed.join();
  var hReverse3 = row3.split('').reversed.join();
  var hReverse4 = row4.split('').reversed.join();
  var hReverse5 = row5.split('').reversed.join();

  for (var answer in [hReverse1, hReverse2, hReverse3, hReverse4, hReverse5]) {
    var epmtyIndex = answer.indexOf("#");
    if (epmtyIndex == 4 || epmtyIndex == 0) {
      answer = answer.split("#").join();
    }
    solution.removeWhere((solution) => solution == answer);
  }

  //ceck vertical
  var col1Sort = updatedBox.where((box) => box.tile.x == 1).toList();
  col1Sort.sort(((a, b) => a.tile.y.compareTo(b.tile.y)));
  var col2Sort = updatedBox.where((box) => box.tile.x == 2).toList();
  col2Sort.sort(((a, b) => a.tile.y.compareTo(b.tile.y)));
  var col3Sort = updatedBox.where((box) => box.tile.x == 3).toList();
  col3Sort.sort(((a, b) => a.tile.y.compareTo(b.tile.y)));
  var col4Sort = updatedBox.where((box) => box.tile.x == 4).toList();
  col4Sort.sort(((a, b) => a.tile.y.compareTo(b.tile.y)));
  var col5Sort = updatedBox.where((box) => box.tile.x == 5).toList();
  col5Sort.sort(((a, b) => a.tile.y.compareTo(b.tile.y)));

  var col1 = col1Sort.map((col) => col.letter != '' ? col.letter : '#').join();
  var col2 = col2Sort.map((col) => col.letter != '' ? col.letter : '#').join();
  var col3 = col3Sort.map((col) => col.letter != '' ? col.letter : '#').join();
  var col4 = col4Sort.map((col) => col.letter != '' ? col.letter : '#').join();
  var col5 = col5Sort.map((col) => col.letter != '' ? col.letter : '#').join();

  // print(row1Sort.map((col) => col.letter != '' ? col.letter : '#'));
  // print(row2Sort.map((col) => col.letter != '' ? col.letter : '#'));
  // print(row3Sort.map((col) => col.letter != '' ? col.letter : '#'));
  // print(row4Sort.map((col) => col.letter != '' ? col.letter : '#'));
  // print(row5Sort.map((col) => col.letter != '' ? col.letter : '#'));

  for (var answer in [col1, col2, col3, col4, col5]) {
    var epmtyIndex = answer.indexOf("#");
    if (epmtyIndex == 4 || epmtyIndex == 0) {
      answer = answer.split("#").join();
    }
    solution.removeWhere((solution) => solution == answer);
  }

  //check Vertical reverse
  var cReverse1 = col1.split('').reversed.join();
  var cReverse2 = col2.split('').reversed.join();
  var cReverse3 = col3.split('').reversed.join();
  var cReverse4 = col4.split('').reversed.join();
  var cReverse5 = col5.split('').reversed.join();

  for (var answer in [cReverse1, cReverse2, cReverse3, cReverse4, cReverse5]) {
    var epmtyIndex = answer.indexOf("#");
    if (epmtyIndex == 4 || epmtyIndex == 0) {
      answer = answer.split("#").join();
    }
    solution.removeWhere((solution) => solution == answer);
  }

  // print(solution);

  return solution;

  // if (solution.isEmpty) {
  //   return true;
  // }

  // return false;
}

Box _updateBox(Box currentBox, Box selectedBox) {
  if (currentBox.tile.x == selectedBox.tile.x &&
      currentBox.tile.y == selectedBox.tile.y) {
    currentBox.selected = true;
  } else {
    currentBox.selected = false;
  }

  return currentBox;
}

List<dynamic> updateBoxesProp(
    List<Box> currentBoxesProp, Box selectedBox, num steps) {
  var newBoxProps = currentBoxesProp
      .map<Box>((currentBox) => _updateBox(currentBox, selectedBox))
      .toList();

  var selectedBoxIndex = newBoxProps.indexWhere((box) =>
      box.tile.x == selectedBox.tile.x && box.tile.y == selectedBox.tile.y);

  var newBox = currentBoxesProp[selectedBoxIndex];
  var posxTemp = newBox.startPosX;
  var posyTemp = newBox.startPosY;
  var tileXTemp = newBox.tile.x;
  var tileYtemp = newBox.tile.y;
  var tempNeghbours = newBox.neighbour;
  var leftNb = selectedBox.neighbour.left;
  var rightNb = selectedBox.neighbour.right;
  var topNb = selectedBox.neighbour.top;
  var bottomNb = selectedBox.neighbour.bottom;

  var rightBoxIndex = newBoxProps.indexWhere((element) =>
      rightNb != null &&
      element.tile.x == rightNb.x &&
      element.tile.y == rightNb.y);
  var rightBox = rightBoxIndex == -1 ? null : newBoxProps[rightBoxIndex];

  var leftBoxIndex = newBoxProps.indexWhere((element) =>
      leftNb != null &&
      element.tile.x == leftNb.x &&
      element.tile.y == leftNb.y);
  var leftBox = leftBoxIndex == -1 ? null : newBoxProps[leftBoxIndex];

  var topBoxIndex = newBoxProps.indexWhere((element) =>
      topNb != null && element.tile.x == topNb.x && element.tile.y == topNb.y);
  var topBox = topBoxIndex == -1 ? null : newBoxProps[topBoxIndex];

  var bottomBoxIndex = newBoxProps.indexWhere((element) =>
      bottomNb != null &&
      element.tile.x == bottomNb.x &&
      element.tile.y == bottomNb.y);
  var bottomBox = bottomBoxIndex == -1 ? null : newBoxProps[bottomBoxIndex];

  if (rightBox != null && rightBox.empty) {
    //swap box location
    newBox.startPosX = rightBox.startPosX;
    newBox.startPosY = rightBox.startPosY;
    rightBox.startPosX = posxTemp;
    rightBox.startPosY = posyTemp;

    //swap box coordinate
    newBox.tile.x = rightBox.tile.x;
    newBox.tile.y = rightBox.tile.y;
    rightBox.tile.x = tileXTemp;
    rightBox.tile.y = tileYtemp;

    //swap neighbours

    newBox.neighbour = rightBox.neighbour;
    rightBox.neighbour = tempNeghbours;

    steps++;
  } else if (leftBox != null && leftBox.empty) {
    //swap box location
    newBox.startPosX = leftBox.startPosX;
    newBox.startPosY = leftBox.startPosY;
    leftBox.startPosX = posxTemp;
    leftBox.startPosY = posyTemp;

    //swap box coordinate
    newBox.tile.x = leftBox.tile.x;
    newBox.tile.y = leftBox.tile.y;
    leftBox.tile.x = tileXTemp;
    leftBox.tile.y = tileYtemp;

    //swap neighbours
    newBox.neighbour = leftBox.neighbour;
    leftBox.neighbour = tempNeghbours;
    steps++;
  } else if (topBox != null && topBox.empty) {
    //swap box location
    newBox.startPosX = topBox.startPosX;
    newBox.startPosY = topBox.startPosY;
    topBox.startPosX = posxTemp;
    topBox.startPosY = posyTemp;

    //swap box coordinate
    newBox.tile.x = topBox.tile.x;
    newBox.tile.y = topBox.tile.y;
    topBox.tile.x = tileXTemp;
    topBox.tile.y = tileYtemp;

    //swap neighbours
    newBox.neighbour = topBox.neighbour;
    topBox.neighbour = tempNeghbours;
    steps++;
  } else if (bottomBox != null && bottomBox.empty) {
    //swap box location
    newBox.startPosX = bottomBox.startPosX;
    newBox.startPosY = bottomBox.startPosY;
    bottomBox.startPosX = posxTemp;
    bottomBox.startPosY = posyTemp;

    //swap box coordinate
    newBox.tile.x = bottomBox.tile.x;
    newBox.tile.y = bottomBox.tile.y;
    bottomBox.tile.x = tileXTemp;
    bottomBox.tile.y = tileYtemp;

    //swap neighbours
    newBox.neighbour = bottomBox.neighbour;
    bottomBox.neighbour = tempNeghbours;
    steps++;
  }

  return [newBoxProps, steps];
}
