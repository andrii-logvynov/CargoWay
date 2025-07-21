String tStr = 'aaaaa bbbbb ccccc ddddd eeeeee fffff ggggg 11111 22222 33333 44444';
List<String> baseList = tStr.split(' ');
List<String> bigList = baseList;
Map<Integer, List<String>> SampleMap = new Map<Integer, List<String>>();
SampleMap.put(1, bigList);

for (Integer i = 0; i < 20; i++) {
    List<String> tempList = new List<String>();
    tempList = SampleMap.get(1);
    bigList.addAll(tempList);
}