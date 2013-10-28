package {

    public class Edge {

        public var v1:Vector2;
        public var v2:Vector2;
        public var normal1:Vector2;
        public var normal2:Vector2;

        public var color:uint = 0x999999;
        public var canGrow:Boolean = true;

        public function Edge(v1:Vector2, v2:Vector2) {
            this.v1 = v1;
            this.v2 = v2;

            var d:Vector2 = v2.sub(v1);
            var n:Vector2 = new Vector2(d.y, -d.x);

            normal1 = n.mul( 1 / n.len() );
            normal2 = normal1.copy();
        }

        public function toString():String {
            return v1.toString() + "->" + v2.toString();
        }

    }

}