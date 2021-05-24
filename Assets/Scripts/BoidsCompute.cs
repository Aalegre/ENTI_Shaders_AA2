using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoidsCompute : MonoBehaviour
{
    public struct GameObjectInfo
    {
        public Vector3 position;
        public Vector3 velocity;
        public static int Size
        {
            get
            {
                return sizeof(float) * 3 * 2;
            }
        }
    }

    public GameObject prefab;
    public ComputeShader shader;

    public int numObjectsPerRow = 10;
    List<GameObject> objects;
    ComputeBuffer dataBuffer;
    GameObjectInfo[] data;
    // Start is called before the first frame update
    void Start()
    {
        //We create the objects to move
        objects = new List<GameObject>(numObjectsPerRow * numObjectsPerRow);
        for (int i = 0; i < numObjectsPerRow; i++)
        {
            for (int j = 0; j < numObjectsPerRow; j++)
            {
                GameObject newObj = Instantiate(prefab, transform);
                newObj.transform.position = transform.position + Vector3.up * i * 0.5f + Vector3.right * j * 0.5f;
                objects.Add(newObj);
            }
        }
        //we generate the data array to pass data from CPU to GPU at the initialization, and don't release the buffer until destroy is called

        int numObjs = objects.Count;
        data = new GameObjectInfo[numObjs];
        for (int i = 0; i < numObjs; i++)
        {
            data[i].position = objects[i].transform.position;
            data[i].velocity = Vector3.forward;
        }
        //We create the buffer to pass data to the GPU
        //The constructor asks for an ammount of objects for the buffer and the size of each object in bytes
        dataBuffer = new ComputeBuffer(numObjs, GameObjectInfo.Size);
        //We load the data into the buffer
        dataBuffer.SetData(data);
    }

    // Update is called once per frame
    void Update()
    {

        //we generate the data array to pass data from CPU to GPU
        int numObjs = objects.Count;
        int kernelHandle = shader.FindKernel("CSMain");
        shader.SetBuffer(kernelHandle, "CoolerResult", dataBuffer);

        shader.SetFloat("deltaTime", Time.deltaTime);

        int threadGroups = Mathf.CeilToInt(numObjs / 128.0f);

        shader.Dispatch(kernelHandle, threadGroups, 1, 1);

        dataBuffer.GetData(data);
        for (int i = 0; i < numObjs; i++)
        {
            objects[i].transform.position = data[i].position;
        }

        // dataBuffer.Release();
    }

    public void OnDestroy()
    {
        foreach (Transform child in transform)
        {
            GameObject.Destroy(child.gameObject);
        }
        dataBuffer.Release();
    }


}
