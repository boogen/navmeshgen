package {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import flash.events.*;
    import flash.ui.Keyboard;

    public class Main extends Sprite {

        private var points:Vector.<Vector2> = new Vector.<Vector2>();
        private var pointSprites:Vector.<Sprite> = new Vector.<Sprite>();
        private var triangles:Vector.<Triangle> = new Vector.<Triangle>();

        private var bottom:Sprite;
        private var current:Vector.<Sprite>;
        private var top:Sprite;

        private var positive_polygons:Vector.<Polygon> = new Vector.<Polygon>();
        private var negative_polygons:Vector.<Polygon> = new Vector.<Polygon>();

        private var mode:Boolean = true;
        private var divided:Dictionary = new Dictionary();

        private var seeds:Vector.<Vector2> = new Vector.<Vector2>();

        public function Main() {
            if (stage) {
                init();
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);


            current = new Vector.<Sprite>();

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

            bottom = new Sprite();
            addChild(bottom);


            top = new Sprite();
            addChild(top);


            var btn:Sprite = new Sprite();
            btn.graphics.beginFill(0x0000ff);
            btn.graphics.drawRect(0, 0, 50, 20);
            btn.graphics.endFill();
            addChild(btn);
            btn.addEventListener(MouseEvent.MOUSE_UP, onToggle);


        }

        private function onToggle(e:MouseEvent):void {
            mode = !mode;
            e.stopImmediatePropagation();
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.G) {
                generate();
            }
        }

        private function generate():void {
            for each (var poly:Polygon in positive_polygons) {
                for each (var e:Edge in poly.edges) {
                    var m:Vector2 = (e.v1.add(e.v2)).mul(0.5);
                    m = m.add(e.normal1.mul(30));
                    seeds.push(m);
                }
            }

            for (var i:int = 0; i < seeds.length; ++i) {
                var p:Vector2 = seeds[i];
                trace("check: ", p);
                if (!insidePolygon(positive_polygons, p)) {
                    marshmallows(p.copy());
                    positive_polygons = positive_polygons.concat(negative_polygons);
                    negative_polygons.length = 0;
                    trace("polygons ", positive_polygons.length);
                }
            }
        }

        private function canMove(polys:Vector.<Polygon>, e:Edge):Boolean {
            return inStage(e) && isColliding(polys, e) == null  && !insidePolygon(polys, e.v1) && !insidePolygon(polys, e.v2);
        }

        private function tryToMove(polys:Vector.<Polygon>, polygon:Polygon, newedge:Edge, edge:Edge):Boolean {
            if (canMove(polys, newedge)) {
                var temp1:Vector2 = edge.v1.copy();
                var temp2:Vector2 = edge.v2.copy();
                edge.v1.x = newedge.v1.x;
                edge.v1.y = newedge.v1.y;

                edge.v2.x = newedge.v2.x;
                edge.v2.y = newedge.v2.y;

                if (!polygon.isConvex()) {
                    edge.v1.x = temp1.x;
                    edge.v1.y = temp1.y;
                    edge.v2.x = temp2.x;
                    edge.v2.y = temp2.y;
                }
                else {
                    return true;
                }
                
            }

            return false;
            
        }

        private function marshmallows(seed:Vector2):void {
            var stillgrowing:Boolean = true;
            
            var points:Vector.<Vector2> = new Vector.<Vector2>();
            points.push(seed);
            points.push(new Vector2(seed.x + 1, seed.y));
            points.push(new Vector2(seed.x + 1, seed.y + 1));
            points.push(new Vector2(seed.x, seed.y + 1));
            var polygon:Polygon = new Polygon(points);
            polygon.color = 0xeeeeee;
            polygon.showPoints = false;
            negative_polygons.push(polygon);

            var polys:Vector.<Polygon> = negative_polygons.concat(positive_polygons);

            var counter:int = 0;
            while (stillgrowing) {
                counter++;
                stillgrowing = false;
                for each (var polygon:Polygon in negative_polygons) {
                    for (var i:int = 0; i < polygon.edges.length; ++i) {
                        var e:Edge = polygon.edges[i];

                        if (!e.canGrow) {
                            continue;
                        }

                        var e1:Edge = new Edge(e.v1.add(e.normal1), e.v2.add(e.normal2));

                        if (tryToMove(polys, polygon, e1, e)) {
                            stillgrowing = true;
                        }
                        else {

                            var edge:Edge = getCollision(polys, e1);
                            if (edge != null) {

                                var dir:Vector2 = edge.v2.sub(edge.v1);
                               
                                if (dir.len() != 0 && ! ( edge in polygon.divided) ) {
                                    polygon.divided[edge] = true;

                                    if ( endIntersects(e1, edge) ) {
                                        var nextEdge:Edge = polygon.edges[ ( i + 1 ) % polygon.edges.length ];
                                        insertBetween(polygon, e, nextEdge, dir);
                                        stillgrowing = true;


                                    }
                                    else if (beginningIntersects(e1, edge) ) {

                                        var index:int = i - 1;
                                        if (index < 0) {
                                            index = polygon.edges.length - 1;
                                        }
                                        var prevEdge:Edge = polygon.edges[ index];
                                        insertBetween(polygon, prevEdge, e, dir);
                                        stillgrowing = true;

                                    }

                                }
                            }
                        }
                        
                    }
                }
            }

        }

        private function insertBetween(polygon:Polygon, e1:Edge, e2:Edge, dir:Vector2):void {
            if (dir.x != 0 && dir.y != 0) {
                if (Math.abs(e1.normal2.x) < Math.abs(e1.normal2.y) ) {
                    e1.normal2 = dir.mul( 1 / Math.abs(dir.y) );
                    e2.normal1 = dir.mul( -1 / Math.abs(dir.x) );
                }
                else {
                    e1.normal2 = dir.mul( 1 / Math.abs(dir.x) );
                    e2.normal1 = dir.mul( -1 / Math.abs(dir.y) );
                }
            }
            else {
                dir = dir.mul( 1 / dir.len());
                e1.normal2 = dir.copy();
                e2.normal1 = dir.mul( -1);
            }
                                    

            var new_v:Vector2 = e1.v2.copy();
            e1.v2 = new_v;

            var new_edge:Edge = new Edge(e1.v2, e2.v1);
            new_edge.canGrow = false;

            var index:int = polygon.edges.indexOf(e1);
            polygon.points.splice(index + 1, 0, e1.v2);
            polygon.edges.splice(index + 1, 0, new_edge);

        }


        

        private function inStage(e:Edge):Boolean {
            return pointInStage(e.v1) && pointInStage(e.v2);
        }

        private function pointInStage(p:Vector2):Boolean {
            return ! ( p.x < 0 || p.x > stage.stageWidth || p.y < 0 || p.y > stage.stageHeight );
        }

        private function isColliding(polys:Vector.<Polygon>, e:Edge):Edge {
            for each (var p:Polygon in polys) {
                for each (var edge:Edge in p.edges) {
                    if ( intersects( e, edge ) ) {
                        return edge;
                    }
                }
            }
       
            return null;
        }

        private function getCollision(polys:Vector.<Polygon>, e:Edge):Edge {
            for each (var p:Polygon in polys) {
                for each (var edge:Edge in p.edges) {
                    if ( beginningIntersects( e, edge ) || endIntersects(e, edge ) ) {
                        return edge;
                    }
                }
            }
       
            return null;
        }

        private function findTS(e1:Edge, e2:Edge):Vector2 {
            var result:Vector2;
            var a:Vector2 = e1.v1;
            var b:Vector2 = e1.v2.sub(e1.v1);

            var c:Vector2 = e2.v1;
            var d:Vector2 = e2.v2.sub(e2.v1);

            
            if (d.cross(b) != 0) {
                var s:Number = a.sub(c).cross(b) / d.cross(b);
                var t:Number = a.sub(c).cross(d) / d.cross(b);

                result = new Vector2(t, s);

            }

            return result;
            
            
        }

        private function endIntersects(e1:Edge, e2:Edge):Boolean {
            var ts:Vector2 = findTS(e1, e2);
         
            if (ts != null && ts.y > 0 && ts.y < 1) {
                var b:Vector2 = e1.v2.sub(e1.v1);

                if ( b.sub(b.mul(ts.x)).len() <= 2) {
                    return true;
                }
            }

            return false;
        }

        private function beginningIntersects(e1:Edge, e2:Edge):Boolean {
            var ts:Vector2 = findTS(e1, e2);
         
            if (ts != null && ts.y > 0 && ts.y < 1) {
                var b:Vector2 = e1.v2.sub(e1.v1);

                if ( b.mul(ts.x).len() <= 2 ) {
                    return true;
                }
            }

            return false;
        }
        


        private function intersects(e1:Edge, e2:Edge):Boolean {
            var a:Vector2 = e1.v1;
            var b:Vector2 = e1.v2.sub(e1.v1);

            if (b.len() == 0) {
                return false;
            }

            var c:Vector2 = e2.v1;
            var d:Vector2 = e2.v2.sub(e2.v1);

            if (d.len() == 0) {
                return false;
            }

            if (d.cross(b) != 0) {
                var s:Number = a.sub(c).cross(b) / d.cross(b);
                var t:Number = a.sub(c).cross(d) / d.cross(b);

                return s >= 0 && s <= 1 && t >= 0 && t <= 1;
            }

            if (a.sub(c).cross(d) == 0) {
                var p1:Vector2 = e1.v1.sub(e2.v1);
                var p2:Vector2 = e1.v2.sub(e2.v1);

                if (p1.dot(p2) < 0) {
                    return true;
                }

                var q1:Vector2 = e1.v1.sub(e2.v2);
                var q2:Vector2 = e1.v2.sub(e2.v2);

                return q1.dot(p2) < 0;
            }
            
            return false;
        }

        private function onMouseUp(e:MouseEvent):void {
            if (mode) {
                addPoint(e.stageX, e.stageY);
            }
            else {
                var seed:Vector2  = new Vector2(e.stageX, e.stageY);

                marshmallows(seed);
                
                positive_polygons = positive_polygons.concat(negative_polygons);
                negative_polygons.length = 0;
            }
         
        }

        private function addPoint(px:Number, py:Number):void {
            var v:Vector2 = new Vector2(px, py);

            points.push(v);

            var p:Sprite = new Dragable(stage, v, points.length - 1);
            p.x = px;
            p.y = py;
            addChild(p);
            pointSprites.push(p);

            if (current.length >= 3) {
                current.length = 0;
            }

            current.push(p);
            addTriangle();

        }


        private function addTriangle():void {
            if (current.length >= 3) {
                var indices:Vector.<int> = new Vector.<int>();
                
                var points:Vector.<Vector2> = new Vector.<Vector2>();
                for (var i:int = 0; i < current.length; ++i) {
                    points.push(new Vector2(current[i].x, current[i].y));
                }

                var polygon:Polygon = new Polygon(points);
                polygon.color = 0xeeee00;
                positive_polygons.push(polygon);
            }

        }

        private function drawPoly(p:Polygon, color:uint, showNormals:Boolean):void {
            bottom.graphics.beginFill(color, p.alpha);

                    

            bottom.graphics.moveTo(p.edges[0].v1.x, p.edges[0].v1.y);

            for (var i:int = 0; i < p.edges.length; ++i) {
                bottom.graphics.lineStyle(1, p.edges[i].color);
                bottom.graphics.lineTo(p.edges[i].v2.x, p.edges[i].v2.y);
            }
            bottom.graphics.endFill();

            if (p.showPoints) {
                for each (var v:Vector2 in p.points) {
                    bottom.graphics.beginFill(p.edges[0].color);
                    bottom.graphics.drawCircle(v.x, v.y, 4);
                    bottom.graphics.endFill();
                }
            }

            if (showNormals) {
                for each (var e:Edge in p.edges) {
                    if (!e.canGrow) {
                        continue;
                    }
                    bottom.graphics.moveTo(e.v1.x, e.v1.y);
                    var d:Vector2 = e.normal1.mul(16);
                    bottom.graphics.lineTo(e.v1.x + d.x, e.v1.y + d.y);
                    
                    bottom.graphics.beginFill(0xff0000);
                    bottom.graphics.drawCircle(e.v1.x + d.x, e.v1.y + d.y, 2);
                    bottom.graphics.endFill();
                

                    bottom.graphics.moveTo(e.v2.x, e.v2.y);
                    d = e.normal2.mul(16);
                    bottom.graphics.lineTo(e.v2.x + d.x, e.v2.y + d.y);

                    bottom.graphics.beginFill(0xff0000);
                    bottom.graphics.drawCircle(e.v2.x + d.x, e.v2.y + d.y, 2);
                    bottom.graphics.endFill();
                    
                }
            }

        }


        private function tick(e:Event):void {
            bottom.graphics.clear();
            
            for each (var p:Polygon in positive_polygons) {
                drawPoly(p, p.color, false);
            }


            if (current.length < 3 && current.length > 0) {
                for (var i:int = 0; i < current.length; ++i) {
                    bottom.graphics.beginFill(0xff0000);
                    bottom.graphics.drawCircle(current[i].x, current[i].y, 4);
                    bottom.graphics.endFill();
                }
            }

            for (var i:int = 0; i < seeds.length; ++i) {
                    bottom.graphics.beginFill(0x00ff00);
                    bottom.graphics.drawCircle(seeds[i].x, seeds[i].y, 4);
                    bottom.graphics.endFill();

            }

            addChild(top);
            top.graphics.clear();

        }

        private function insidePolygon(polys:Vector.<Polygon>, p:Vector2):Boolean {
            for each (var poly:Polygon in polys) {
                if (poly.inside(p)) {
                    return true;
                }
            }

            return false;
        }


        private function insideTriangle(px:Number, py:Number):int {
            for (var i:int = 0; i < triangles.length; ++i) {
                if (triangles[i].inside(px, py)) {
                    return i;
                }
            }

            return -1;
            
        }


    }
}