#load the XML into doc as a string
tiles = []
isList = False
with open("JonTronMap.dam", "r") as in_file:
    for line in in_file:
        if line.find("<tileProperties>") != -1:
            break
        if line.find("<row>") != -1 and isList == False:
            isList = True
        if isList == True:
            line = line.lstrip("        <row>").rstrip("</row>\n").split(",")
            for tile in range(0, len(line)):
                line[tile] = int(line[tile])
            tiles.append(line)
#cut the tile numbers out of the file


'''verticalDistance/horizontalDistance: how many tiles down you want to move.
Negative y values move up, negative x values move left. rowLength for the
OverWorld tileSet = 40. tileNumbers: a list containing the specific numbered
tiles you want to relocate. startValue/endValue: every tile between these
values will be moved.'''
def displace(verticalDistance, horizontalDistance, rowLength, tileNumbers, startValue, endValue):
    #arrange tiles to be increased into a list
    tilesToMove = []
    if tileNumbers != None:
        tilesToMove = tileNumbers
    if startValue >= 0 and endValue > 0:
        for i in range(startValue, endValue+1):
            tilesToMove.append(i)

    #search each line and change values as needed
    for row in range(0, len(tiles)):
        for tile in range(0, len(tiles[row])):
            if tiles[row][tile] in tilesToMove:
                tiles[row][tile] = tiles[row][tile]+verticalDistance*rowLength+horizontalDistance

def export():
    exportDoc = ""
    for row in range(0, len(tiles)):
        line = str(tiles[row]).lstrip("[").rstrip("]").replace(" ", "")
        line = "        <row>" + line + "</row>\n"
        exportDoc = exportDoc + line
    print exportDoc

displace(3, 0, 40, None, 200, 1279)
export()
