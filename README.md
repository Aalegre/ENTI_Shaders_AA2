# ENTI-Shaders - AA2

## Participants
* Arnau Tarrago
* Alberto Alegre

## Implementation

### Post processing
#### Vignetting/Blur/Pixelate
We used the post processing effects that we created for the last practice, and created a custom Vignetting.
For the context aware, we used a local volume inside the water and changed the effects to give the illusion of being inside water.
### Shader in Unity
#### PBR shadows
We changed the PBR material to use shadows and sample a color texture
#### Create materials
In `Assets/Materials` there are custom materials for each object of the scene
### Compute Shaders
#### Boids
In this project, we have created Boids for fish and for seagulls. Although both use the same mechanics, they have different settings. In the scene, it can be found under the "BOIDS" section. The Boids implementation has been organized in the following scripts:
* **Boid**: this script is assigned to each Boid element. Its function is to update the boid's position using all of the relevant factors such as alignment force, cohesion force, separation force, etc. These forces are calculated using values that are NOT calculated in this script, but rather in the Compute shader. It also checks whether the Boid is heading towards an obstacle using a forward Sphere Cast, which if it's the case it will activate its obstacle avoidance system by casting multiple sphere casts in all directions. It will also take into account whether a manual target has been set, and prioritize following said target; in this exercise, however, no target has been set.
* **BoidHelper**: this script is a static class used to help the Boid script. Its main purpose is to give the Boid a determinate amount of equal directions to use when the obstacle avoidance system has been activated. It achieves this purpose by using math magic that I don't understand and that I had to look up; the golden ratio is involved to accomplish directions that are perfectly equalized between each other and to make sure there are no blind spots when sphere casting.
* **BoidManager**: there is one BoidManager for each type of Boid; in this case, one for Fish and one for Seagulls. At the start of this script, it gathers all of the Boids in the scene, puts them in a list for easy management, initializes the Boids with any settings found and sets their manual target to follow if any exist (in this project there is no target, so it's null). We also make sure to handle the creation of the buffer and data at the start of the function and not in the update in order to make the data buffer persistent, thus optimizing the script. We also dispose of the buffer when exiting the application. The purpose of the update is to use the Compute Shader attached to calculate in parallel the needed Boid's values and then update the Boids in the list. 
* **BoidSettings**: this is a ScriptableObject that is used to create custom settings for each type of Boid. Two exist: one for Fish, one for Seagulls. The following parameters exist:
    * ***Min Speed***: the minimum speed the Boid can move at.
    * ***Max Speed***: the maximum speed the Boid can achieve.
    * ***Perception Radius***: the distance in which the Boid considers other Boids of the same type for force calculations. 
    * ***Avoidance Radius***: the distance in which the Boid will try to distance itself from other Boids.
    * ***Max Steer Force***: a clamp to limit the value of the various forces when steering towards a point.
    * ***Align Weigh***t: how much importance is given for Boids to remain aligned with each other.
    * ***Cohesion Weight***: how much importance is given for Boids to remain together with each other. 
    * ***Seperate Weight***: how much importance is given for Boids to remain seperate with each other.
    * ***Target Weight***: how much importance is given for Boids to follow the target, if it exists.
    * ***Obstacle Mask***: which Layers the Boid will consider as an obstacle in its calculations.
    * ***Bounds Radius***: the width of the Sphere Cast used when checking for collisions. Ideally should be equal to the collider of the Game Object.
    * ***Avoid Collision Weight***: how much importance is given for Boids to evade collisions. This value tends to be high as it is only activated when an obstacle is detected, and it needs to override almost all other weights to make sure it doesn't crash.
    * ***Collision Avoid Dst***: the distance in which the Boid considers obstacles. Max distance for the Sphere Casts used.
    
* **BoidsComputeShader**: the Compute Shader where the magic happens. Using the GPU's parallelization, it gets all the Boids from the BoidManager and compares each one with all the rest. Using the perception radius, it calculates whether a boid has any flockmates and if so, updates its flock heading, flock centre and separation heading, which will be used to calculate the align, cohesion and seperate forces respectively. Of note is that we use the square root of distance to compare distances as the call to calculate the mgnitude of a vector is quite complicated and takes longer to execute than normal arithmetic opertions. Calculating the squared magnitude instead of the magnitude is much faster, which is what we do here.

* **Spawner**: this script spawns a determinate amount of Boids of a specific type. We use Unity's "insideUnitSphere" value to randomize the spawn of the Boids.

### Additional Implementatios
#### Vertex shader animation
We have decided to simulate mud getting crushed and displaced as the Vertex Shader animation. In the scene, it can be found under the "VERTEX SHADERS" section. It has been organized in the following elements:

* **DrawTrack** ***(Script)***: This script is used to handle the settings for the shader. It keeps track of the "brushes" (which in this case will be the spheres) that will draw on the splatmap and assign a temporary material with the DrawTracks shader attached. Each frame, we will send to the shader the values of the coordinates where the spheres have touched the plane, the strength of the brush and the size of the brush. 
* **DrawTracks** ***(Shader)***: The shader will sample the splatmap texture, and a mask texture, multiplying them. Then offset the resulting 0-1 value by a certain amount along the mesh normals. We also used texture blending to show two different surfaces when the mesh is sunk or not.
 
#### Texture animation
Using the Time variables that unity enables we created a custom water shader. 
We offset the UVs, to sample a normal texture 2 times and blend them. We use these normals, and some more offset on the uvs to call a voronoi function.
### Rogue Exercise
#### Texture Blending
We used texture blending on the DrawTracks shader, and in the water shader.
