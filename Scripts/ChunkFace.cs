using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChunkFace
{
    private ChunkFace parentChunk;
    private ChunkFace[] chunkTree;

    private int chunkSize;
    private float scale;
    private float radius;
    private int level;

    private Vector3 position;
    private Vector4 positionToDraw;
    private Camera camera;

    private Bounds bounds;
    public bool generated;

    private List<Vector4> positionsList = new List<Vector4>();
    private List<Vector4> directionList = new List<Vector4>();

    private List<Vector4>[] positionsListArray = new List<Vector4>[4];
    private List<Vector4>[] directionListArray = new List<Vector4>[4];

    private Vector3 directionX;
    private Vector3 directionY;

    private Vector3 normal;

    private bool isVisible;

    private string myDirection;

    public ChunkFace(ChunkFace parent, Vector3 position, float scale, Camera viewer, Vector3 directionX, Vector3 directionY, float radius, bool isVisible, int level, string myDirection)
    {
        this.parentChunk = parent;
        this.position = position;
        this.scale = scale;

        this.directionX = directionX;
        this.directionY = directionY;
        this.radius += radius;
        this.camera = viewer;
        this.level = level;
        this.myDirection = myDirection;

        this.isVisible = isVisible;
        InitLists();
        generated = true;
        Vector3 newPosition = CalculePositionOfSphere();

        normal = newPosition.normalized;

        bounds = new Bounds(newPosition, newPosition.normalized * scale);

        positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);

        Update(viewer.transform.position, isVisible);
    }

    private void InitLists()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i] = new List<Vector4>();
            directionListArray[i] = new List<Vector4>();
        }
    }
    private Vector3 CalculePositionOfSphere()
    {
        float x = position.x / radius;
        float y = position.y / radius;
        float z = position.z / radius;

        float dx = x * Mathf.Sqrt(1.0f - (y * y * 0.5f) - (z * z * 0.5f) + (y * y * z * z / 3.0f));
        float dy = y * Mathf.Sqrt(1.0f - (z * z * 0.5f) - (x * x * 0.5f) + (z * z * x * x / 3.0f));
        float dz = z * Mathf.Sqrt(1.0f - (x * x * 0.5f) - (y * y * 0.5f) + (x * x * y * y / 3.0f));

        return new Vector3(dx, dy, dz) * radius;
    }

    public void Update(Vector3 viewerPositon, bool isStillVisible)
    {
        if (isStillVisible)
        {
            isVisible = FrustumCulling.Frustum(camera, bounds.center, scale * 0.5f, normal);
        }

        var dist = Vector3.Distance(viewerPositon, bounds.ClosestPoint(viewerPositon));

        if (parentChunk != null)
        {
            var distParent = Vector3.Distance(viewerPositon, parentChunk.GetBounds().ClosestPoint(viewerPositon));

            if (distParent / 2 > parentChunk.GetScale())
            {
              
                parentChunk.MergeChunk();
                return;
            }
        }


        if (scale * 2 > dist)
        {
            SubDivide(viewerPositon);
        }

        if (chunkTree != null)
        {
            foreach (var item in chunkTree)
            {
                item.Update(viewerPositon, isVisible);
            }
        }

        //   Debug.Log(level);
        return;
    }

    public void GetPosition2()
    {
        ClearPositionAndDirection();
        Vector4 newDirection = new Vector4(directionX.x, directionX.y, directionX.z, 1);
        if(parentChunk == null)
        {
            positionsListArray[0].Add(positionToDraw);
            directionListArray[0].Add(newDirection);
            return;
        }

        Vector4 edge = parentChunk.FindEnge(myDirection);

        if (edge.x == 1 || edge.y == 1 || edge.z == 1 || edge.w == 1)
        {
            positionsListArray[1].Add(positionToDraw);
            directionListArray[1].Add(newDirection);
        }
        else
        {
            positionsListArray[0].Add(positionToDraw);
            directionListArray[0].Add(newDirection);
        }

     /*   positionsListArray[0].Add(positionToDraw);
        directionListArray[0].Add(newDirection);*/

    }

    public void ClearPositionAndDirection()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i].Clear();
            directionListArray[i].Clear();
        }
    }

    public Vector4 FindEnge(string direction)
    {
        Vector4 activeEdge;
        float right = 0;
        float left = 0;
        float bottom = 0;
        float top = 0;
        Stack<string> myStack = new Stack<string>();
 
        if(chunkTree == null)
        {
            activeEdge = new Vector4(top, right, bottom, left);
            return activeEdge;
        }
        switch (direction)
        {
            case "lefttop":             
                right = chunkTree[1].IsHasChild();
                bottom = chunkTree[2].IsHasChild();
                if (parentChunk != null)
                {
                    left = 0;//parentChunk.FindEdge("left", myStack, "left") ? 1 : 0;
                    top = 0;// parentChunk.FindEdge("top", myStack, "top") ? 1 : 0;
                }
                break;
            case "righttop":
                left = chunkTree[0].IsHasChild();
                bottom = chunkTree[3].IsHasChild();
                if (parentChunk != null)
                {
                    right = 0;//parentChunk.FindEdge("right", myStack, "right") ? 1 : 0;
                    top = 0;//parentChunk.FindEdge("top", myStack, "top") ? 1 : 0;
                }
                break;
            case "leftbottom":
                top = chunkTree[0].IsHasChild();
                right = chunkTree[3].IsHasChild();
                if (parentChunk != null)
                {
                    left = 0;//parentChunk.FindEdge("left", myStack, "left") ? 1 : 0;
                    bottom = 0;//parentChunk.FindEdge("bottom", myStack, "bottom") ? 1 : 0;
                }
                break;
            case "rightbottom":
                top = chunkTree[1].IsHasChild();
                left = chunkTree[2].IsHasChild();
                if (parentChunk != null)
                {

                    right = 0; //parentChunk.FindEdge("right", myStack, "right") ? 1 : 0;
                    bottom = 0;// parentChunk.FindEdge("bottom", myStack, "bottom") ? 1 : 0;
                }
                break;
            default:
                break;
        }

        activeEdge = new Vector4(top, right, bottom, left);

        return activeEdge;
    }

    public bool FindEdge(string baseDirection, Stack<string> positionsList, string ask)
    {
        if (baseDirection != ask && parentChunk != null)
        {
            return FindEdgeInsite(positionsList, ask);
        }
        else if (parentChunk != null)
        {
            positionsList.Push(baseDirection);
            return parentChunk.FindEdge(myDirection, positionsList, ask);
        }

        return false;
    }

    public bool FindEdgeInsite(Stack<string> positionStack, string direction)
    {

        if (positionStack.Count == 0)
        {
            return true;
        }
        else if (parentChunk == null)
        {
            return false;
        }

        string backDirection = positionStack.Pop();
        bool isEdge = false;

        switch (direction)
        {
            case "right":
                backDirection = backDirection.Replace(direction, "left");
                break;
            case "left":
                backDirection = backDirection.Replace(direction, "right");
                break;
            case "top":
                backDirection = backDirection.Replace(direction, "bottom");
                break;
            case "bottom":
                backDirection = backDirection.Replace("top", direction);
                break;
        }

        switch (backDirection)
        {
            case "lefttop":
                isEdge = chunkTree[0].FindEdgeInsite(positionStack, direction);
                break;
            case "righttop":
                isEdge = chunkTree[1].FindEdgeInsite(positionStack, direction);
                break;
            case "leftbottom":
                isEdge = chunkTree[2].FindEdgeInsite(positionStack, direction);
                break;
            case "rightbottom":
                isEdge = chunkTree[3].FindEdgeInsite(positionStack, direction);
                break;
        }

        return isEdge;


    }

    private float CalculeTessellatio(float distance)
    {
        if (distance > 800)
        {
            return 0;
        }
        else
        {
            float tessellation = 1 - (distance - scale * 2) / (scale * 2);
            return tessellation;
        }
    }

    public ChunkFace[] getChunkTree()
    {
        return chunkTree;
    }

    public Bounds GetBounds()
    {
        return bounds;
    }

    public float GetScale()
    {
        return scale;
    }

    public Vector4 GetPositionToDraw()
    {
        return positionToDraw;
    }

    public Vector3 GetPosition()
    {
        return position;
    }

    public ChunkFace GetParrent()
    {
        return parentChunk;
    }

    public List<Vector4> GetPositionList()
    {
        return positionsList;
    }

    public List<Vector4> GetDirectionList()
    {
        return directionList;
    }

    public List<Vector4>[] findDirection()
    {
        return directionListArray;
    }

    public List<Vector4>[] findAllChunkToDraw()
    {
        ClearPositionAndDirection();
        if (!isVisible)
        {
            return null;
        }

    
        if (chunkTree == null)
        {
            ClearPositionAndDirection();
            GetPosition2();
          
            return positionsListArray;
        }
        else
        {
            ClearPositionAndDirection();
          //  Debug.Log(chunkTree.Length);
            foreach (var chunk in chunkTree)
            {
                
                List<Vector4>[] pom = chunk.findAllChunkToDraw();
                List<Vector4>[] pomDir = chunk.findDirection();
                
                if(pom == null)
                {
                    continue;
                }

                for (int i = 0; i < 4; i++)
                {
                    positionsListArray[i].AddRange(pom[i]);
                    directionListArray[i].AddRange(pomDir[i]);
                   /* if (positionsListArray[i].Count > 0)
                        Debug.Log(positionsListArray[i].Count);*/
                }
            }         
        }

        return positionsListArray;
    }

    public float IsHasChild()
    {
        if (chunkTree != null)
        {
            return 1;
        }
        return 0;
    }

    public void MergeChunk()
    {
        if (chunkTree == null)
            return;

        for (int i = 0; i < chunkTree.Length; i++)
        {
            chunkTree[i].MergeChunk();
        }

        chunkTree = null;

        ClearPositionAndDirection(); 
    }

    public void SubDivide(Vector3 viewerPosition)
    {

        if (chunkTree != null)
        {
            foreach (var item in chunkTree)
            {
                item.Update(viewerPosition, isVisible);
            }
        }
        else
        {
            float newScale = scale * 0.5f;

            Vector3 left = (directionX * scale / 4);
            Vector3 forward = (directionY * scale / 4);

            chunkTree = new ChunkFace[] {
                new ChunkFace(this, position - left + forward,  newScale, camera, directionX, directionY, radius, isVisible, level + 1, "lefttop"),
                new ChunkFace(this, position + left + forward,  newScale, camera, directionX, directionY, radius, isVisible, level + 1, "righttop"),
                new ChunkFace(this, position - left - forward,  newScale, camera, directionX, directionY, radius, isVisible, level + 1, "leftbottom"),
                new ChunkFace(this, position + left - forward,  newScale, camera, directionX, directionY, radius, isVisible, level + 1, "rightbottom")
            };

        }
    }

    public bool GetGenerate()
    {
        return generated;
    }

    public void SetGenerated(bool isGenerate)
    {
        generated = isGenerate;
    }
}