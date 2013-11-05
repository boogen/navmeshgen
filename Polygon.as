package {

    import flash.utils.*;
    
    public class Polygon {

        public var points:Vector.<Vector2>;
        public var edges:Vector.<Edge>;
        public var divided:Dictionary = new Dictionary();
        public var color:uint;
        public var vertex_color:uint = Math.floor(Math.random() * 0xffffff);
        public var alpha:Number = 1;
        public var showPoints:Boolean = true;

        public function Polygon(points:Vector.<Vector2>) {
            this.points = points;

            checkOrientation();

            edges = new Vector.<Edge>();

            for (var i:int = 0; i < points.length; ++i) {
                var v1:Vector2 = points[i];
                var v2:Vector2 = points[ ( i + 1 ) % points.length ];
                
                var e:Edge = new Edge(v1, v2);
                edges.push(e);
            }

        }

        public function insertEdge(v:Vector2):Edge {
            var edge_index:int;
            for (var i:int = 0; i < edges.length; ++i) {
                var e:Edge = edges[i];
                if (e.vertices[1] == v) {
                    edge_index = i;
                    break;
                }
            }

            var vertex_index:int;
            for (var i:int = 0; i < points.length; ++i) {
                if (points[i] == v) {
                    vertex_index = i;
                    break;
                }
            }

            edges[edge_index].normals[1] = new Vector2(0, 0);

            var new_v:Vector2 = v.copy();
            points.splice(vertex_index + 1, 0, new_v);

            var next_edge:Edge = edges[ (edge_index + 1) % edges.length ];
            next_edge.vertices[0] = new_v;
            next_edge.normals[0] = new Vector2(0, 0);

            var edge:Edge = new Edge(v, new_v);
            edges.splice(edge_index + 1, 0, edge);

            return edge;
            
        }

        public function insertAfter(v1:Vector2, v2:Vector2):void {
            var index:int = points.indexOf(v1);
            points.splice(index + 1, 0, v2);
        }

        public function isConvex():Boolean {
            for (var i:int = 0; i < points.length; ++i) {
                var p1:Vector2 = points[ ( i + 1 ) % points.length].sub(points[i]);
                var p2:Vector2 = points[ ( i + 2 ) % points.length].sub(points[ ( i + 1 ) % points.length]);

                if (p1.cross(p2) < 0) {
                    return false;
                }
            }

            return true;

        }

        public function checkOrientation():void {
            var p1:Vector2 = points[1].sub(points[0]);
            var p2:Vector2 = points[2].sub(points[1]);

            if (p1.cross(p2) < 0) {
                points.reverse();
            }

        }


        public function inside(p:Vector2):Boolean {

            for (var i:int = 0; i < points.length; ++i) {
                var p1:Vector2 = points[i];
                var p2:Vector2 = points[ ( i + 1 ) % points.length ];

                var v1:Vector2 = p2.sub(p1);
                var v2:Vector2 = p.sub(p1);

                var cross:Number= v1.cross(v2);

                if (cross < 0) {
                    return false;
                }
            }

            return true;

        }


    }
}