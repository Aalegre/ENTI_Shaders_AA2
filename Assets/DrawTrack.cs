using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawTrack : MonoBehaviour
{
    private RenderTexture splatmap;
    public Shader drawShader;
    private Material drawMaterial;
    private Material myMaterial;
    public GameObject terrain;
    RaycastHit groundHit;
    int layerMask;

    [Range(1, 500)]
    public float brushSize;
    [Range(0, 1)]
    public float brushStrength;

    // Start is called before the first frame update
    void Start()
    {
        layerMask = LayerMask.GetMask("Mud");
        drawMaterial = new Material(drawShader);
        myMaterial = terrain.GetComponent<MeshRenderer>().material;
        myMaterial.SetTexture("_Splat", splatmap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat));
    }

    // Update is called once per frame
    void Update()
    {
        if (Physics.Raycast(transform.position, Vector3.down, out groundHit, 1f, layerMask))
        {
            drawMaterial.SetVector("_Coordinates", new Vector4(groundHit.textureCoord.x, groundHit.textureCoord.y, 0, 0));
            drawMaterial.SetFloat("_Strength", brushStrength);
            drawMaterial.SetFloat("_Size", brushSize);
            RenderTexture temp = RenderTexture.GetTemporary(splatmap.width, splatmap.height, 0, RenderTextureFormat.ARGBFloat);

            Graphics.Blit(splatmap, temp);
            Graphics.Blit(temp, splatmap, drawMaterial);
            RenderTexture.ReleaseTemporary(temp);
        }
    }
}
