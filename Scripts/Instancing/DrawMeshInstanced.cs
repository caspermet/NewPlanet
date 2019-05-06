using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawMeshInstanced  {

    int instanceCount = 100000;
    Mesh instanceMesh;
    Material instanceMaterial;
    int subMeshIndex = 0;
    Vector4[] positions;
    Vector4[] directions;

    ComputeBuffer positionBuffer;
    ComputeBuffer argsBuffer;
    ComputeBuffer directionBuffer;
    uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    MaterialPropertyBlock MaterialPropertyBlock;

    public DrawMeshInstanced(Mesh instanceMesh)
    {
        this.instanceMesh = instanceMesh;      

    }

    public void UpdateData (int instanceCount, Vector4[] positions, Vector4[] directions, int meshIndex, Material instanceMaterial, MaterialPropertyBlock materialPropertyBlock)
    {

        this.instanceCount = instanceCount; 
        this.positions = positions;
        this.directions = directions;
        this.subMeshIndex = meshIndex;

        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        this.instanceMaterial = instanceMaterial;
        this.MaterialPropertyBlock = materialPropertyBlock;

        UpdateBuffers(instanceMaterial);
    }   

    public void Draw()
    {
        Graphics.DrawMeshInstancedIndirect(instanceMesh, subMeshIndex, instanceMaterial, new Bounds(Vector3.zero, new Vector3(10000000.0f, 10000000.0f, 10000000.0f)), argsBuffer, 0, MaterialPropertyBlock, UnityEngine.Rendering.ShadowCastingMode.Off);
    }

    public  void UpdateBuffers(Material instanceMaterial)
    {
        if (positionBuffer != null)
            positionBuffer.Release();
      
        positionBuffer = new ComputeBuffer(instanceCount, 16);

        positionBuffer.SetData(positions);
   
        MaterialPropertyBlock.SetBuffer("positionBuffer", positionBuffer);
        if (directionBuffer != null)
            directionBuffer.Release();
        directionBuffer = new ComputeBuffer(instanceCount, 16);

        directionBuffer.SetData(directions);
      
        MaterialPropertyBlock.SetBuffer("directionsBuffer", directionBuffer);

        // Indirect args
        if (instanceMesh != null)
        {
            args[0] = (uint)instanceMesh.GetIndexCount(subMeshIndex);
            args[1] = (uint)instanceCount;
            args[2] = (uint)instanceMesh.GetIndexStart(subMeshIndex);
            args[3] = (uint)instanceMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args[0] = args[1] = args[2] = args[3] = 0;
        }

        argsBuffer.SetData(args);

    }

    public void Disable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;
        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;
        if (directionBuffer != null)
            directionBuffer.Release();
        directionBuffer = null;
    }
}