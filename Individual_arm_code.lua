function sysCall_init()
    corout=coroutine.create(coroutineMain)
    cylinder= sim.getObject("/Cylinder")
    graph= sim.getObject("/Graph")
    cyl_y= sim.addGraphStream(graph, "y", "dist", 0, {1,0,0})
    
end

function sysCall_actuation()
    if coroutine.status(corout)~='dead' then
        local ok,errorMsg=coroutine.resume(corout)
        if errorMsg then
            error(debug.traceback(corout,errorMsg),2)
        end
    end
end


function sysCall_sensing()
    cylinder_pos = sim.getObjectPosition(cylinder, sim.handle_world)
    sim.setGraphStreamValue (graph, cyl_y,cylinder_pos[2])
end

-- This is a threaded script, and is just an example!

function movCallback(config,vel,accel,handles)
    for i=1,#handles,1 do
        if sim.isDynamicallyEnabled(handles[i]) then
            sim.setJointTargetPosition(handles[i],config[i])
        else    
            sim.setJointPosition(handles[i],config[i])
        end
    end
end

function moveToConfig(handles,maxVel,maxAccel,maxJerk,targetConf)
    local currentConf={}
    for i=1,#handles,1 do
        currentConf[i]=sim.getJointPosition(handles[i])
    end
    sim.moveToConfig(-1,currentConf,nil,nil,maxVel,maxAccel,maxJerk,targetConf,nil,movCallback,handles)
end

function coroutineMain()
    local jointHandles={}
    for i=1,6,1 do
        jointHandles[i]=sim.getObject('./Joint',{index=i-1})
    end

    local connection=sim.getObject('./connection')
    local gripper=sim.getObjectChild(connection,0)
    local gripperName="NiryoNoGripper"
    if gripper~=-1 then
        gripperName=sim.getObjectAlias(gripper,4)
    end

    -- Set-up some of the RML vectors:
    local vel=20
    local accel=40
    local jerk=80
    local maxVel={vel*math.pi/180,vel*math.pi/180,vel*math.pi/180,vel*math.pi/180,vel*math.pi/180,vel*math.pi/180}
    local maxAccel={accel*math.pi/180,accel*math.pi/180,accel*math.pi/180,accel*math.pi/180,accel*math.pi/180,accel*math.pi/180}
    local maxJerk={jerk*math.pi/180,jerk*math.pi/180,jerk*math.pi/180,jerk*math.pi/180,jerk*math.pi/180,jerk*math.pi/180}
    
    sim.wait(90) 
    local targetPos3={0,0,0,0,-90*math.pi/180,0}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos3)
    local targetPos1={109*math.pi/180,-36.5*math.pi/180,48.5*math.pi/180,0*math.pi/180,-87*math.pi/180,20*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos1)
    
    print("Robot 4 waits for Robot 3")
    local s=sim.waitForSignal("fromRobot3")
    if s then      
        sim.addStatusbarMessage("Robot 4 received signal from Robot 3")
        sim.setInt32Signal(gripperName..'_close',1)
        sim.clearStringSignal("fromRobot3")
    end
    sim.wait(20)
    
    local targetPos6={109*math.pi/180,-20*math.pi/180,33.5*math.pi/180,0*math.pi/180,-90*math.pi/180,20*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos6)
    
    local targetPos7={109*math.pi/180,10*math.pi/180,15*math.pi/180,0*math.pi/180,-90*math.pi/180,20*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos7)
    

    local targetPos4={110.5*math.pi/180,0*math.pi/180,30*math.pi/180,0*math.pi/180,-90*math.pi/180,20*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos4)
    

    
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos3)
    
    local targetPos5={-90*math.pi/180,0*math.pi/180,0*math.pi/180,180*math.pi/180,0*math.pi/180,0*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos5)
    
    
    
    local targetPos2={-90*math.pi/180,-30*math.pi/180,-20*math.pi/180,180*math.pi/180,-50*math.pi/180,-10*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos2)
    sim.wait(10)
    sim.clearInt32Signal(gripperName..'_close')
    sim.wait(20)
    local targetPos8={-90*math.pi/180,-30*math.pi/180,0*math.pi/180,180*math.pi/180,-50*math.pi/180,-10*math.pi/180}
    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos8)

    moveToConfig(jointHandles,maxVel,maxAccel,maxJerk,targetPos3)

end
