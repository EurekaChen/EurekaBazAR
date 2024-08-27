# World
World.lua 分解成三个文件，分别
1. RealityInfo.lua
2. RealityParameters.lua
3. RealityEntitiesStatic.lua

按照常规，在运行AOS时，可以使用-load 加载，-load RealityInfo.lua  -load RealityParameters.lua -load RealityEntitiesStatic.lua  参数来加载这三个文件。但是经测试好象无效果，所以暂时不用。而是运行 LoadWorld.bat 后，在AOS中分别加载这三个文件。 

其中Casino部分设计好了，但Reality Viewer好象加载不出来，没有找到原因。World的Warp可以通往Casino。   





