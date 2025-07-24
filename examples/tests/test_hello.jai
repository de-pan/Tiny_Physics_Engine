
test_hello :: () {

  environmentDistance :: ( point: TPE_Vec3,  maxDistance: TPE_Unit) -> TPE_Vec3
  {
    return TPE_envGround(point,0); // just an infinite flat plane
  }

  body: TPE_Body;
  world: TPE_World;
  joint: TPE_Joint;
  frame: s32 = 0;

  joint = TPE_joint(TPE_vec3(0,TPE_F * 8,0),TPE_F);
  TPE_bodyInit(*body,*joint,1, null,0,2 * TPE_F);
  TPE_worldInit(*world,*body,1,environmentDistance);

  while (TPE_bodyIsActive(*body))
  {
    if (frame % 6 == 0) // print once in 6 frames
    {
      height := TPE_bodyGetCenterOfMass(*body).y;

      i: s32; while  i < (height * 4) / TPE_F { defer i+=1;
        print(" ");
      }

      print("*");
    }

    TPE_bodyApplyGravity(*body,TPE_F / 100);
    TPE_worldStep(*world);
    frame+=1;
  }
  

  print("body deactivated");

}