package {
    public class Vector2 {
        
        public var x:Number;
        public var y:Number;

        public var history:Vector.<Vector2>;

        public function Vector2(x:Number = 0, y:Number = 0) {
            this.x = x;
            this.y = y;

            history = new Vector.<Vector2>();
        }

        public function store():void {
            history.push(this.copy());
        }

        public function restore():void {
            var v:Vector2 = history.pop();
            x = v.x;
            y = v.y;
        }

        public function cross(v:Vector2):Number {
            return this.x * v.y - this.y * v.x;
        }

        public function dot(v:Vector2):Number {
            return this.x * v.x + this.y * v.y;
        }

        public function sub(v:Vector2):Vector2 {
            return new Vector2(x - v.x, y - v.y);
        }

        public function add(v:Vector2):Vector2 {
            return new Vector2(x + v.x, y + v.y);
        }

        public function mul(s:Number):Vector2 {
            return new Vector2(x * s, y * s);
        }

        public function len():Number {
            return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
        }

        public function normalize():Vector2 {
            var length:Number = len();
            return new Vector2( x / length, y / length);
        }

        public function copy():Vector2 {
            return new Vector2(x, y);
        }

        public function equals(v:Vector2):Boolean {
            return x == v.x && y == v.y;
        }

        public function toString():String {
            return "(" + x.toString() + "," + y.toString() + ")";
        }
    }
}