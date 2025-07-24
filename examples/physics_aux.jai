//procedures not needed for the physics, but are auxiliary for the examples:

TPE_bodyApplyGravity :: (body: *TPE_Body,  downwardsAccel: TPE_Unit)
{
  if ((body.flags & TPE_BODY_FLAG_DEACTIVATED) ||
      (body.flags & TPE_BODY_FLAG_DISABLED))
    return;

  i:u16; while i < body.jointCount { defer i+=1;
    body.joints[i].velocity[1] -= cast(s16)downwardsAccel;
  }
}


TPE_envGround :: ( point_i: TPE_Vec3,  height: TPE_Unit) -> TPE_Vec3 
{
  point := point_i;
  if (point.y > height)
    point.y = height;

  return point;
}


TPE_envAABoxInside :: ( point_i: TPE_Vec3,  center: TPE_Vec3,  size_i: TPE_Vec3) -> TPE_Vec3 
{
    size := size_i;
    point := point_i;
  size.x /= 2;
  size.y /= 2;
  size.z /= 2;

   shifted: TPE_Vec3 = TPE_vec3Minus(point,center);

   a:TPE_Vec3 = TPE_vec3Minus(size,shifted);
    b:TPE_Vec3 = TPE_vec3Plus(shifted,size);

  sx: s8 = 1;
   sy: s8 = 1;
    sz: s8 = 1;

  if (b.x < a.x)
  {
    a.x = b.x;
    sx = -1;
  }

  if (b.y < a.y)
  {
    a.y = b.y;
    sy = -1;
  }

  if (b.z < a.z)
  {
    a.z = b.z;
    sz = -1;
  }

  if (a.x < 0 || a.y < 0 || a.z < 0)
    return point;

  if (a.x < a.y)
  {
    if (a.x < a.z)
      point.x = center.x + sx * size.x;
    else
      point.z = center.z + sz * size.z;
  }
  else
  {
    if (a.y < a.z)
      point.y = center.y + sy * size.y;
    else
      point.z = center.z + sz * size.z;
  }

  return point;
}



TPE_makeBox :: (joints: []TPE_Joint,  connections: []TPE_Connection/*[16]TPE_Connection*/,
   width_i: TPE_Unit,  depth_i: TPE_Unit,  height_i: TPE_Unit,  jointSize_i: TPE_Unit)
{
    assert(joints.count == 8);
    assert(connections.count == 16);
    width := width_i;
    depth := depth_i;
    height := height_i;
    jointSize := jointSize_i;
  width /= 2;
  depth /= 2;
  height /= 2;

  i:u8; while i < 8 { defer i+=1;
    joints[i] = TPE_joint( 
      TPE_vec3(  
        ifx (i % 2) then width else (-1 * width),
        ifx ((i >> 2) % 2) then height else (-1 * height),
        ifx ((i >> 1) % 2) then depth else (-1 * depth)),
      jointSize);
  }
// #define C(n,a,b) connections[n].joint1 = a; connections[n].joint2 = b;
    C :: (n: int, a: u8, b: u8, connections: []TPE_Connection) {
        connections[n].joint1 = a; connections[n].joint2 = b;
    }
//  
 C(0, 0,1,connections);
 C(1, 1,3,connections);
 C(2, 3,2,connections);
 C(3, 2,0,connections);  // top
//  
 C(4, 4,5,connections);
 C(5, 5,7,connections);
 C(6, 7,6,connections);
 C(7, 6,4,connections);  // bottom
//  
 C(8, 0,4,connections);
 C(9, 1,5,connections);
 C(10,3,7,connections);
 C(11,2,6,connections);  // middle
//  
 C(12,0,7,connections);
 C(13,1,6,connections);
 C(14,2,5,connections);
 C(15,3,4,connections);  // diagonal
}


TPE_bodyMoveTo :: (body: *TPE_Body,  position_i: TPE_Vec3)
{

  position := TPE_vec3Minus(position_i,TPE_bodyGetCenterOfMass(body));

   i:u8; while i < body.jointCount { defer i+=1;
    body.joints[i].position = TPE_vec3Plus(body.joints[i].position,position);
   }
}



TPE_bodySpinWithCenter :: (body: *TPE_Body,  rotation: TPE_Vec3,  center: TPE_Vec3)
{
  i: u16 = 0; while i < body.jointCount { defer i += 1;

    j: *TPE_Joint = body.joints + i;

     toPoint := TPE_vec3Minus(j.position,center);

    toPoint = TPE_vec3Project(toPoint,rotation);
    toPoint = TPE_vec3Plus(center,toPoint);
    toPoint = TPE_vec3Minus(j.position,toPoint);
    toPoint = TPE_vec3Cross(toPoint,rotation);

    j.velocity[0] += cast(s16)toPoint.x;
    j.velocity[1] += cast(s16)toPoint.y;
    j.velocity[2] += cast(s16)toPoint.z;
  }
}

TPE_bodySpin :: (body: *TPE_Body,  rotation: TPE_Vec3)
{
  TPE_bodySpinWithCenter(body,rotation,TPE_bodyGetCenterOfMass(body));
}


TPE_bodyAccelerate :: (body: *TPE_Body,  velocity: TPE_Vec3)
{
  TPE_bodyActivate(body);

  i: u16 = 0;

  while i < body.jointCount

  {

      defer i += 1;

    body.joints[i].velocity[0] += cast(s16)velocity.x;
    body.joints[i].velocity[1] += cast(s16)velocity.y;
    body.joints[i].velocity[2] += cast(s16)velocity.z;
  }
}



//