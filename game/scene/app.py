"""Panda3D app with a basic table plane and dice physics."""

from __future__ import annotations


class GameApp:
    def __init__(self) -> None:
        self.started = False
        self.loader = None

    def run(self) -> None:
        try:
            from direct.showbase.ShowBase import ShowBase
            from direct.task import Task
            from panda3d.core import (
                AmbientLight,
                BitMask32,
                CardMaker,
                DirectionalLight,
                Plane,
                Point3,
                Vec3,
                Vec4,
            )
            from panda3d.bullet import BulletBoxShape, BulletPlaneShape, BulletRigidBodyNode, BulletWorld
        except Exception as exc:  # pragma: no cover - runtime environment check
            print("Panda3D non disponibile:", exc)
            return

        class App(ShowBase):
            def __init__(self) -> None:
                super().__init__()
                self.disableMouse()
                self.setBackgroundColor(0.15, 0.15, 0.15, 1.0)
                self.dice_nodes = []
                self.world = BulletWorld()
                self.world.setGravity(Vec3(0, 0, -9.81))
                self.camera_target = Point3(0, 0, 0)
                self.is_panning = False
                self.last_mouse = None
                self.launch_start_time = None

                # Camera setup.
                self.camera.setPos(0, 0, 18)
                self.camera.lookAt(self.camera_target)

                # Lighting setup.
                ambient = AmbientLight("ambient")
                ambient.setColor(Vec4(0.2, 0.2, 0.2, 1.0))
                ambient_np = self.render.attachNewNode(ambient)
                self.render.setLight(ambient_np)

                directional = DirectionalLight("directional")
                directional.setColor(Vec4(1.0, 0.95, 0.9, 1.0))
                directional_np = self.render.attachNewNode(directional)
                directional_np.setHpr(45, -45, 0)
                self.render.setLight(directional_np)

                # Table plane.
                cm = CardMaker("table")
                cm.setFrame(-6, 6, -4, 4)
                table = self.render.attachNewNode(cm.generate())
                table.setPos(0, 0, 0)
                table.setHpr(0, -90, 0)
                table.setColor(0.1, 0.5, 0.1, 1.0)
                table.setTwoSided(True)
                table.setLightOff()

                # Physics ground plane at z=0.
                ground_shape = BulletPlaneShape(Vec3(0, 0, 1), 0)
                ground_node = BulletRigidBodyNode("ground")
                ground_node.addShape(ground_shape)
                ground_np = self.render.attachNewNode(ground_node)
                ground_np.setCollideMask(BitMask32.bit(1))
                self.world.attachRigidBody(ground_node)

                # Mouse picking plane at z=0.
                self.pick_plane = Plane(Vec3(0, 0, 1), Point3(0, 0, 0))

                # Input.
                self.accept("mouse1", self._start_launch)
                self.accept("mouse1-up", self._release_launch)
                self.accept("wheel_up", self._zoom_in)
                self.accept("wheel_down", self._zoom_out)
                self.accept("mouse2", self._start_pan)
                self.accept("mouse2-up", self._stop_pan)
                self.accept("mouse3", self._start_pan)
                self.accept("mouse3-up", self._stop_pan)
                self.taskMgr.add(self._update_physics, "physics-update")
                self.taskMgr.add(self._update_camera, "camera-update")

            def _update_physics(self, task: Task) -> Task:
                dt = globalClock.getDt()
                self.world.doPhysics(dt, 10, 1.0 / 180.0)
                return Task.cont

            def _update_camera(self, task: Task) -> Task:
                if self.is_panning and self.mouseWatcherNode.hasMouse():
                    mouse = self.mouseWatcherNode.getMouse()
                    if self.last_mouse is not None:
                        delta = mouse - self.last_mouse
                        pan_speed = 12.0
                        move = Vec3(-delta.x * pan_speed, -delta.y * pan_speed, 0)
                        self.camera.setPos(self.camera.getPos() + move)
                        self.camera_target += move
                    self.last_mouse = mouse
                self.camera.lookAt(self.camera_target)
                return Task.cont

            def _start_launch(self) -> None:
                self.launch_start_time = globalClock.getRealTime()

            def _release_launch(self) -> None:
                if self.launch_start_time is None:
                    return
                if not self.mouseWatcherNode.hasMouse():
                    self.launch_start_time = None
                    return
                hold_time = max(0.0, globalClock.getRealTime() - self.launch_start_time)
                self.launch_start_time = None
                mouse_pos = self.mouseWatcherNode.getMouse()
                near_point = Point3()
                far_point = Point3()
                self.camLens.extrude(mouse_pos, near_point, far_point)
                near_point = self.render.getRelativePoint(self.cam, near_point)
                far_point = self.render.getRelativePoint(self.cam, far_point)
                hit = Point3()
                if not self.pick_plane.intersectsLine(hit, near_point, far_point):
                    return
                self._spawn_dice(hit, hold_time)

            def _zoom_in(self) -> None:
                pos = self.camera.getPos()
                self.camera.setPos(pos.x, pos.y, max(5.0, pos.z - 1.0))

            def _zoom_out(self) -> None:
                pos = self.camera.getPos()
                self.camera.setPos(pos.x, pos.y, min(40.0, pos.z + 1.0))

            def _start_pan(self) -> None:
                self.is_panning = True
                if self.mouseWatcherNode.hasMouse():
                    self.last_mouse = self.mouseWatcherNode.getMouse()
                else:
                    self.last_mouse = None

            def _stop_pan(self) -> None:
                self.is_panning = False
                self.last_mouse = None

            def _spawn_dice(self, position: Point3, hold_time: float) -> None:
                hold_scale = max(0.6, min(2.0, 0.6 + hold_time * 1.2))
                for index in range(2):
                    spawn = Point3(position.x + (index * 0.6), position.y, position.z + 2.0)
                    body = BulletRigidBodyNode("dice")
                    body.setMass(1.0)
                    shape = BulletBoxShape(Vec3(0.25, 0.25, 0.25))
                    body.addShape(shape)
                    dice_np = self.render.attachNewNode(body)
                    dice_np.setPos(spawn)
                    dice_np.setCollideMask(BitMask32.bit(1))
                    self.world.attachRigidBody(body)

                    try:
                        model = self.loader.loadModel("models/box")
                        model.reparentTo(dice_np)
                        model.setScale(0.5)
                        model.setColor(0.9, 0.9, 0.9, 1.0)
                    except Exception:
                        cm = CardMaker("dice_face")
                        cm.setFrame(-0.25, 0.25, -0.25, 0.25)
                        face = dice_np.attachNewNode(cm.generate())
                        face.setColor(0.9, 0.9, 0.9, 1.0)

                    # Add randomness to make the roll feel physical.
                    import random

                    impulse = Vec3(
                        random.uniform(-0.4, 0.4) * hold_scale,
                        random.uniform(1.2, 2.0) * hold_scale,
                        random.uniform(4.0, 5.0) * hold_scale,
                    )
                    torque = Vec3(
                        random.uniform(-0.8, 0.8) * hold_scale,
                        random.uniform(-0.8, 0.8) * hold_scale,
                        random.uniform(-0.8, 0.8) * hold_scale,
                    )
                    body.applyCentralImpulse(impulse)
                    body.applyTorqueImpulse(torque)
                    body.setAngularDamping(0.2)
                    body.setLinearDamping(0.05)
                    self.dice_nodes.append(dice_np)

        self.started = True
        app = App()
        app.run()
