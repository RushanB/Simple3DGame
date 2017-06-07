//
//  GameViewController.swift
//  Simple3DGame
//
//  Created by Rushan on 2017-06-06.
//  Copyright © 2017 RushanBenazir. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    
    var gameView: SCNView! //allows you to attach all of your nodes
    var gameScene: SCNScene! //attach a game
    var cameraNode: SCNNode! //camera
    var targetCreationTime: TimeInterval = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call initializers
        initView()
        initScene()
        initCamera()
    
    }
    
    //initialize the view
    func initView(){
        gameView = self.view as! SCNView  //cast as scene view
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self //assign delegate
    }
    
    //initialize the scene
    func initScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        //enters pause mode, so have to make sure its playing
        gameView.isPlaying = true
        
    }
    
    //initialize the camera
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera() //access the camera
        
        cameraNode.position = SCNVector3(x:0, y:5, z:10)
        
        //allows you to see the entire scene
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    
    //many types of objects we can create (sphere, triangle)
    func createTarget(){
        let geometry: SCNGeometry = SCNPyramid(width:1, height:1, length:1 )
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        
        geometry.materials.first?.diffuse.contents = randomColor
        //to add it to our scene, create a geo node
        let geometryNode = SCNNode(geometry: geometry)
        
        //static does not move but other objects collide with it
        //dynamics move with other objects
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        //give our node a color based on the action
        if randomColor == UIColor.red {
            geometryNode.name = "enemy"
        }else{
            geometryNode.name = "friends"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        //random
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        
        //pyramids are foced to left or right
        let force = SCNVector3(x:randomDirection ,y:15, z:0)
        
        //have it as an impusle, apply foce once not continously
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y:0.05, z: 0.05),asImpulse: true)
        
    }
    
    //creates targets at intervals
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime{
            createTarget()
            targetCreationTime = time + 0.6
        }
    }
    
    //which of our objects was touched by the user
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get a touch
        let touch = touches.first!
        //create a location object in our gameview
        let location = touch.location(in: gameView)
        
        let hitList = gameView.hitTest(location, options: nil)
        //use first object out of hit list
        if let hitObject = hitList.first {
            //friend or enemy
            let node = hitObject.node
            
            if node.name == "friend"{
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.black
            }else{
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
        }
    }
    
    //function to clean up the invisible objects in memory
    func cleanUp(){
        for node in gameScene.rootNode.childNodes{
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
