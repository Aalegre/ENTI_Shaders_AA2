using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoidManager : MonoBehaviour
{

    public string boidTag;
    const int threadGroupSize = 1024;
    public BoidSettings settings;
    public ComputeShader compute;
    private ComputeBuffer boidBuffer;
    private int numBoids;
    private BoidData[] boidData;
    List<Boid> boids;

    void Start()
    {
        boids = new List<Boid>();

        GameObject[] auxList = GameObject.FindGameObjectsWithTag(boidTag);
        foreach (GameObject go in auxList)
        {
            Boid auxB = go.GetComponent<Boid>();
            boids.Add(auxB);
            auxB.Initialize(settings, null);
        }

        if(boids != null)
        {
            numBoids = boids.Count;
            boidBuffer = new ComputeBuffer(numBoids, BoidData.Size);

            boidData = new BoidData[numBoids];

            for (int i = 0; i < boids.Count; i++)
            {
                boidData[i].position = boids[i].position;
                boidData[i].direction = boids[i].forward;
            }

            boidBuffer.SetData(boidData);
        }

    }

    void Update()
    {
        if (boids != null)
        {
            compute.SetBuffer(0, "boids", boidBuffer);
            compute.SetInt("numBoids", boids.Count);
            compute.SetFloat("viewRadius", settings.perceptionRadius);
            compute.SetFloat("avoidRadius", settings.avoidanceRadius);

            int threadGroups = Mathf.CeilToInt(numBoids / (float)threadGroupSize);
            compute.Dispatch(0, threadGroups, 1, 1);

            boidBuffer.GetData(boidData);

            for (int i = 0; i < boids.Count; i++)
            {
                boids[i].avgFlockHeading = boidData[i].flockHeading;
                boids[i].centreOfFlockmates = boidData[i].flockCentre;
                boids[i].avgAvoidanceHeading = boidData[i].avoidanceHeading;
                boids[i].numPerceivedFlockmates = boidData[i].numFlockmates;

                boids[i].UpdateBoid();
            }
        }
    }

    public struct BoidData
    {
        public Vector3 position;
        public Vector3 direction;

        public Vector3 flockHeading;
        public Vector3 flockCentre;
        public Vector3 avoidanceHeading;
        public int numFlockmates;

        public static int Size
        {
            get
            {
                return sizeof(float) * 3 * 5 + sizeof(int);
            }
        }
    }

    private void OnApplicationQuit()
    {
        boidBuffer.Dispose();
    }
}