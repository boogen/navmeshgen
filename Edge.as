package {

    public class Edge {

        public var vertices:Vector.<Vector2>;
        public var normals:Vector.<Vector2>;
        public var color:uint = 0x999999;

        public function Edge(v1:Vector2, v2:Vector2) {

            vertices = new Vector.<Vector2>();
            vertices.push(v1);
            vertices.push(v2);

            normals = new Vector.<Vector2>();

            var d:Vector2 = v2.sub(v1);
            var n:Vector2 = new Vector2(d.y, -d.x);
            n = n.normalize();

            normals.push(n.copy());
            normals.push(n.copy());
            
        }

        public function toString():String {
            return vertices[0].toString() + "->" + vertices[1].toString();
        }


        public function grow(i:int):Edge {
            var v1:Vector2 = vertices[i].copy();
            vertices[i].store();
            vertices[i].x += normals[i].x;
            vertices[i].y += normals[i].y;
            var v2:Vector2 = vertices[i].copy();

            return new Edge(v1, v2);
        }

        public function reverse(i:int):void {
            vertices[i].restore();
        }

        public function middle():Vector2 {
            return (vertices[0].add(vertices[1])).mul(0.5);
        }
    }

}