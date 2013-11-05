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

/*
            addPoint(293, 349);
            addPoint(358, 287);
            addPoint(440, 404);

            marshmallow(new Vector2(295, 263));
            marshmallow(new Vector2(449, 317));
            marshmallow(new Vector2(339, 384));
*/

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
        }


        private function createPolygon(seed:Vector2):Polygon {
            var points:Vector.<Vector2> = new Vector.<Vector2>();
            points.push(seed);
            points.push(new Vector2(seed.x + 1, seed.y));
            points.push(new Vector2(seed.x + 1, seed.y + 1));
            points.push(new Vector2(seed.x, seed.y + 1));
            var polygon:Polygon = new Polygon(points);
            polygon.color = 0xeeeeee;
            polygon.showPoints = false;

            return polygon;
        }

        private function marshmallow(seed:Vector2):void {
            if (insidePolygon(positive_polygons, seed)) {
                return;
            }

            negative_polygons.push(createPolygon(seed));
            var polys:Vector.<Polygon> = negative_polygons.concat(positive_polygons);
        }

        private function grow():Boolean {
            var stillgrowing:Boolean = false;

                
                for each (var polygon:Polygon in negative_polygons) {
                    for (var i:int = 0; i < polygon.edges.length; ++i) {
                        var edge:Edge = polygon.edges[i];

                        for (var j:int = 0; j < 2; ++j) {
                            if (edge.normals[j].len() > 0) {
                                var dir_edge:Edge = edge.grow(j);
                                var e1:Edge = isColliding(positive_polygons, dir_edge);
                                var e2:Edge = isColliding(positive_polygons, edge);
                                var e3:Edge;
                                if (j == 0) {
                                    var prev:int = i - 1;
                                    if (prev < 0) {
                                        prev = polygon.edges.length - 1;
                                    }
                                    e3 = isColliding(positive_polygons, polygon.edges[prev]);
                                }
                                else {
                                    e3 = isColliding(positive_polygons, polygon.edges[ ( i + 1 ) % polygon.edges.length ]);
                                }
                                if ( inStage(edge.vertices[j]) && polygon.isConvex()) {
                                    if (e1 == null && e2 == null && e3 == null) {
                                        stillgrowing = true;
                                    }
                                    else if (e1 != null  && ! ( e1 in polygon.divided ) ) {
                                        polygon.divided[e1] = true;
                                        edge.reverse(j);
                                        stillgrowing = true
                                        var newedge:Edge = polygon.insertEdge(edge.vertices[j]);
                                        newedge.normals[0] = (e1.vertices[1].sub(e1.vertices[0])).normalize();
                                        newedge.normals[1] = (e1.vertices[0].sub(e1.vertices[1])).normalize();
                                        e1.color = 0xff0000;
                                        edge.normals[j] = new Vector2(0, 0);

                                    }
                                    else {
                                        edge.reverse(j);
                                    }
                                }
                                else {
                                    edge.reverse(j);
                                }
                            }

                        }
                    }
                }
            

            if (!stillgrowing) {
                trace("finished");
                positive_polygons = positive_polygons.concat(negative_polygons);
                negative_polygons.length = 0;
            }

            return stillgrowing;
        }



        private function inStage(p:Vector2):Boolean {
            return ! ( p.x < 0 || p.x > stage.stageWidth || p.y < 0 || p.y > stage.stageHeight );
        }

        private function checkPolygon(polys:Vector.<Polygon>, p:Polygon):Boolean {
            for each (var e:Edge in p.edges) {
                if ( isColliding(polys, e) ) {
                    return false;
                }
            }

            return true;
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



        private function intersects(e1:Edge, e2:Edge):Boolean {
            var a:Vector2 = e1.vertices[0];
            var b:Vector2 = e1.vertices[1].sub(e1.vertices[0]);

            if (b.len() == 0) {
                return false;
            }

            var c:Vector2 = e2.vertices[0];
            var d:Vector2 = e2.vertices[1].sub(e2.vertices[0]);

            if (d.len() == 0) {
                return false;
            }

            if (d.cross(b) != 0) {
                var s:Number = a.sub(c).cross(b) / d.cross(b);
                var t:Number = a.sub(c).cross(d) / d.cross(b);

                return s >= -0.001 && s <= 1.001 && t >= -0.001 && t <= 1.001;
            }

            if (a.sub(c).cross(d) == 0) {
                var p1:Vector2 = e1.vertices[0].sub(e2.vertices[0]);
                var p2:Vector2 = e1.vertices[1].sub(e2.vertices[0]);

                if (p1.dot(p2) < 0) {
                    return true;
                }

                var q1:Vector2 = e1.vertices[0].sub(e2.vertices[1]);
                var q2:Vector2 = e1.vertices[1].sub(e2.vertices[1]);

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
                trace("marshmallow: ", seed);
                marshmallow(seed);
                
            }
         
        }

        private function addPoint(px:Number, py:Number):void {
            var v:Vector2 = new Vector2(px, py);
            trace("add point ", v);
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

                    

            bottom.graphics.moveTo(p.edges[0].vertices[0].x, p.edges[0].vertices[0].y);

            for (var i:int = 0; i < p.edges.length; ++i) {
                bottom.graphics.lineStyle(1, p.edges[i].color);
                bottom.graphics.lineTo(p.edges[i].vertices[1].x, p.edges[i].vertices[1].y);
            }
            bottom.graphics.endFill();



        }

        private function drawPoints(p:Polygon):void {
            if (true || p.showPoints) {
                for each (var v:Vector2 in p.points) {
                    bottom.graphics.beginFill(p.vertex_color);
                    bottom.graphics.drawCircle(v.x, v.y, 4);
                    bottom.graphics.endFill();
                }
            }
        }


        private function tick(e:Event):void {

            grow();
            bottom.graphics.clear();
            
            for each (var p:Polygon in positive_polygons) {
                drawPoly(p, p.color, false);
            }

            for each (var p:Polygon in negative_polygons) {
                drawPoly(p, p.color, false);
            }


            for each (var p:Polygon in positive_polygons) {
                drawPoints(p);
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

    }
}