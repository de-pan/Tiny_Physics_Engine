
test_hello2 :: () 
{ 
  bodies: [2]TPE_Body;             // we'll have two bodies
  world: TPE_World;

  joints: [32]TPE_Joint;           // joint buffer
  connections: [64]TPE_Connection; // connection buffer

  /* we'll create the first body "by hand", just two joints (spheres) with one
     connection: */
  joints[0] = TPE_joint(TPE_vec3(3 * ROOM_SIZE / 4,ROOM_SIZE / 2,0),TPE_F);
  joints[1] = TPE_joint(TPE_vec3(3 * ROOM_SIZE / 4 + TPE_F * 4,ROOM_SIZE / 2,0),TPE_F);

  connections[0].joint1 = 0;
  connections[0].joint2 = 1;

  TPE_bodyInit(*bodies[0],joints.data,2,connections.data,1,TPE_F);

  /* the other (a "box" approximated by spheres) will be made by the library
     function: */
  box_j :[]TPE_Joint= joints; box_j.count = 8; box_j.data +=2;
  box_c :[]TPE_Connection= connections; box_c.count = 16; box_c.data +=1;
  TPE_makeBox(box_j,box_c,2 * TPE_F, 2 * TPE_F, 2 * TPE_F,TPE_F);
  TPE_bodyInit(*bodies[1],joints.data + 2,8,connections.data + 1,16,TPE_F);
  TPE_bodyMoveTo(*bodies[1],TPE_vec3(ROOM_SIZE / 2,ROOM_SIZE / 2,0));

  TPE_worldInit(*world,bodies.data,2,environmentDistance);

  // give some initial velocities and spins to the bodies:

  TPE_bodyAccelerate(*world.bodies[0],TPE_vec3(-1 * TPE_F / 8,TPE_F / 3, 0));
  TPE_bodySpin(*world.bodies[0],TPE_vec3(0,0,-1 * TPE_F / 25));
  TPE_bodyAccelerate(*world.bodies[1],TPE_vec3(-1 * TPE_F / 2,50,0));
  TPE_bodySpin(*world.bodies[1],TPE_vec3(0,0,TPE_F / 23));

 FRAMES :: 200;

   // simulate 200 steps
  i: s32 = 0; while i <= FRAMES { defer i+=1;
    if (i % 10 == 0) // draw the world every 10 frames
    {
      clearScreen();

      j :u8= 0; while j < world.bodyCount { defer j+=1;
        // draw body joints:
         k := 0; while k < world.bodies[j].jointCount { defer k+=1;
          pos := world.bodies[j].joints[k].position;

          setPixel((pos.x * SCREEN_W) / ROOM_SIZE,
            (pos.y * SCREEN_H) / ROOM_SIZE,".");
        }

        // draw the body center:
        pos := TPE_bodyGetCenterOfMass(*world.bodies[j]);
          
        setPixel((pos.x * SCREEN_W) / ROOM_SIZE,(pos.y * SCREEN_H) / ROOM_SIZE, cast(u8)"A" + j);
      }

      printScreen();
      print("frame %d/%d\n",i,FRAMES);
      print("press return to step");
      // getchar();
    }

    TPE_worldStep(*world); // simulate next tick

    j := 0; while j < world.bodyCount { defer j+=1;
      TPE_bodyApplyGravity(*world.bodies[j],TPE_F / 100);
    }
  }


}


ROOM_SIZE :: (20 * TPE_F);

 environmentDistance :: ( point: TPE_Vec3,  maxDistance: TPE_Unit) -> TPE_Vec3
{
  // our environemnt: just a simple room
  return TPE_envAABoxInside(point,TPE_vec3(ROOM_SIZE / 2,ROOM_SIZE / 2,0),
    TPE_vec3(ROOM_SIZE,ROOM_SIZE,ROOM_SIZE));
}

// the following functions are just for ASCII drawing the world

SCREEN_W :: 32;
SCREEN_H :: 16;

screen: [SCREEN_W * SCREEN_H]u8;

clearScreen :: ()
{
  i := 0; while i < (SCREEN_W * SCREEN_H) { defer i+=1;
    c1 := (i < SCREEN_W || i >= SCREEN_W * (SCREEN_H - 1));
    c2 := ((i % SCREEN_W) == 0 || (i % SCREEN_W) == SCREEN_W - 1);
    screen[i] = ifx c1 then "-".data.* else ifx c2 then "|".data.* else " ".data.*;
  }
}

 setPixel :: (x: s32, y: s32, c: u8)
{
  if (x < 0 || x >= SCREEN_W || y < 0 || y >= SCREEN_H)
    return;

  y = SCREEN_H - 1 - y;

  screen[y * SCREEN_W + x] = c;
}

printScreen :: ()
{
  
  i := 0; while i < 20 { defer i+=1;
    print("\n");
  }

  y := 0; while y < SCREEN_H { defer y+=1;
    x := 0; while x < SCREEN_W { defer x+=1;
      str: string;
      str.data = *screen[y * SCREEN_W + x];
      str.count = 1;
      // str.data = screen[y * SCREEN_W + x];
      // str.count = SCREEN_W;
      print(str);
    }

    print("\n");
  }
}