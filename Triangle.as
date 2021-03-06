package {

    import flash.display.Sprite;
    import flash.geom.Point;

    public class Triangle extends Sprite {

        private var points:Vector.<Vector2>;
        public var indices:Vector.<int>;

        public var color:uint = 0xffff00;

        public function Triangle(points:Vector.<Vector2>, indices:Vector.<int>) {
            this.points = points;
            this.indices = indices;
            
            checkOrientation();
        }

        public function checkOrientation():void {
            var p1:Vector2 = points[indices[1]].sub(points[indices[0]]);
            var p2:Vector2 = points[indices[2]].sub(points[indices[1]]);

            if (p1.cross(p2) < 0) {
                indices.reverse();
            }

        }


        public function inside(px:Number, py:Number):Boolean {
            var result:Number = 0;
            var p:Vector2 = new Vector2(px, py);

            for (var i:int = 0; i < indices.length; ++i) {
                var p1:Vector2 = points[indices[i]];
                var p2:Vector2 = points[indices[ ( i + 1 ) % indices.length ] ];

                var v1:Vector2 = p2.sub(p1);
                var v2:Vector2 = p.sub(p1);

                var cross:Number= v1.cross(v2);

                if (cross <= 0) {
                    return false;
                }
            }

            return true;

        }



    }
}