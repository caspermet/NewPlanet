using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class ChunkFace
{
    private ChunkFace parentChunk;
    public ChunkFace[] chunkTree;

    private int chunkSize;
    private float scale;
    private int level;

    private Vector3 position;
    private Vector3 oldPosition;
    private Vector4 positionToDraw;
    private Camera camera;

    private Bounds bounds;
    public bool generated;

    private List<Vector4> positionsList = new List<Vector4>();
    private List<Vector4> directionList = new List<Vector4>();

    private List<Vector4>[] positionsListArray = new List<Vector4>[4];
    private List<Vector4>[] directionListArray = new List<Vector4>[4];

    private Vector4 directionX;
    private Vector3 directionY;

    private Vector3 viewerPositon;

    private Vector3 normal;

    private bool isVisible;

    private int[] myDirection;

    private ChunkFace[] topLevelneighbor;

    private Vector3 stepLeft;
    private Vector3 stepUp;
    private Vector3[] steps;
    bool isMerge;

    int topNeighbor;
    int rightNeighbor;
    int bottomNeighbor;
    int leftNeighbor;


    public ChunkFace(ChunkFace parent, Vector3 position, float scale, Camera viewer, Vector4 directionX, Vector3 directionY,  bool isVisible, int level, int[] myDirection)
    {
        initialization(parent, position, scale, viewer, directionX, directionY, isVisible, level, myDirection);
    }

    private void initialization(ChunkFace parent, Vector3 position, float scale, Camera viewer, Vector4 directionX, Vector3 directionY,  bool isVisible, int level, int[] myDirection)
    {

        this.parentChunk = parent;
        this.position = position;
        this.oldPosition = position;
        this.scale = scale;

        this.directionX = directionX;
        this.directionY = directionY;
        this.camera = viewer;
        this.level = level;
        this.myDirection = myDirection;
        isMerge = false;
        this.isVisible = isVisible;
        chunkTree = null;
        InitLists();
        generated = true;

        Vector3 newPosition = CalculePositionOfSphere(position);
        bounds = new Bounds(newPosition, newPosition.normalized * scale);
        positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);

        RecalculSteps();

        Update(viewer.transform.position, isVisible, position, scale);
    }

    private void InitLists()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i] = new List<Vector4>();
            directionListArray[i] = new List<Vector4>();
        }
    }

    private Vector3 CalculePositionOfSphere(Vector3 position)
    {
        float x = position.x / PlanetData.PlanetRadius ;
        float y = position.y / PlanetData.PlanetRadius ;
        float z = position.z / PlanetData.PlanetRadius ;

        float dx = x * Mathf.Sqrt(1.0f - (y * y * 0.5f) - (z * z * 0.5f) + (y * y * z * z / 3.0f));
        float dy = y * Mathf.Sqrt(1.0f - (z * z * 0.5f) - (x * x * 0.5f) + (z * z * x * x / 3.0f));
        float dz = z * Mathf.Sqrt(1.0f - (x * x * 0.5f) - (y * y * 0.5f) + (x * x * y * y / 3.0f));

        return new Vector3(dx, dy, dz) * PlanetData.PlanetRadius;
    }

    public void Update(Vector3 viewerPositon, bool isStillVisible, Vector3 positionA, float newScale)
    {

        if (positionA != position)
        {
            scale = newScale;
            position = positionA;
            Vector3 newPosition = CalculePositionOfSphere(positionA);
            bounds.center = newPosition;
            bounds.size = newPosition.normalized * scale;
            RecalculSteps();

            positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);
        }
  

        if (isStillVisible)
        {
            isVisible = FrustumCulling.Frustum(camera, bounds.center, scale * 0.5f);
        }

        if (!isVisible)
        {
            return;
        }
 
        var dist = Vector3.Distance(viewerPositon, bounds.ClosestPoint(viewerPositon));
        this.viewerPositon = viewerPositon;
        SetNeighborToNull();

        if (parentChunk != null)
        {
            var distParent = Vector3.Distance(viewerPositon, parentChunk.GetBounds().ClosestPoint(viewerPositon));

            if (distParent / 2 > parentChunk.GetScale())
            {

                parentChunk.MergeChunk();
                isMerge = true;
                return;
            }

        }

        if (chunkTree != null)
        {
            int i = 0;
            foreach (var item in chunkTree)
            {
                item.Update(viewerPositon, isVisible, steps[i], scale * 0.5f);      
                i++;
               
            }

        }
        else if (scale * 2 > dist)
        {
            SubDivide(viewerPositon);
        }

        return;
    }

    private void SetNeighborToNull()
    {
        topNeighbor = 2;
        rightNeighbor = 2;
        bottomNeighbor = 2;
        leftNeighbor = 2;
    }

    private void RecalculSteps()
    {
        stepLeft = (new Vector3(directionX.x, directionX.y, directionX.z) * scale / 4);
        stepUp = (directionY * scale / 4);
        steps = null;
        steps = new Vector3[]
        {
            position - stepLeft + stepUp,
            position + stepLeft + stepUp,
            position - stepLeft - stepUp,
            position + stepLeft - stepUp
        };
    }

    public void GetPosition2()
    {
        ClearPositionAndDirection();
        Vector4 newDirection = new Vector4(directionX.x + directionY.x, directionX.y + directionY.y, directionX.z + directionY.z, directionX.w);
        Vector4 edge;

        int rotate;
        if (parentChunk == null)
        {
            edge.x = topLevelneighbor[0].IsHasChild();
            edge.y = topLevelneighbor[1].IsHasChild();
            edge.z = topLevelneighbor[2].IsHasChild();
            edge.w = topLevelneighbor[3].IsHasChild();
        }
        else
        {
            int[] pomDirection = new int[2] { myDirection[0], myDirection[1] };
            edge = FindEnge(pomDirection);
        }



        int suma = (int)(edge.x + edge.y + edge.z + edge.w);
        rotate = CalculRotate.CalculRotateOfMesh(edge, suma);

        newDirection.w += rotate;
        if (suma > 3)
        {
            suma = 3;
        }

        positionsListArray[suma].Add(positionToDraw);
        directionListArray[suma].Add(newDirection);

        if (edge.x == 1 || edge.y == 1 || edge.z == 1 || edge.w == 1)
        {
            positionsListArray[suma].Add(positionToDraw);
            directionListArray[suma].Add(newDirection);
        }
        else
        {
            positionsListArray[0].Add(positionToDraw);
            directionListArray[0].Add(newDirection);
        }
    }

    public void ClearPositionAndDirection()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i].Clear();
            directionListArray[i].Clear();
        }
    }

    public Vector4 FindEnge(int[] direction)
    {
        Vector4 activeEdge;
        float right = 0;
        float left = 0;
        float bottom = 0;
        float top = 0;
        Stack<int[]> myStack = new Stack<int[]>();

        if (direction[0] == 0)
        {
            if (direction[1] == 0)
            {
                ///// left-top
                right = parentChunk.chunkTree[1].IsHasChild();
                bottom = parentChunk.chunkTree[2].IsHasChild();

                left = leftNeighbor != 2 ? leftNeighbor : parentChunk.FindEdge(myDirection, myStack, "left") ? 1 : 0;
                myStack.Clear();
                top = topNeighbor != 2 ? topNeighbor : parentChunk.FindEdge(myDirection, myStack, "top") ? 1 : 0;
            }
            else
            {
                ///// right-top
                left = parentChunk.chunkTree[0].IsHasChild();
                bottom = parentChunk.chunkTree[3].IsHasChild();

                right = rightNeighbor != 2 ? rightNeighbor : parentChunk.FindEdge(myDirection, myStack, "right") ? 1 : 0;
                myStack.Clear();
                top = topNeighbor != 2 ? topNeighbor : parentChunk.FindEdge(myDirection, myStack, "top") ? 1 : 0;
            }
        }
        else if (direction[0] == 1)
        {
            if (direction[1] == 0)
            {
                ///// left bottom
                top = parentChunk.chunkTree[0].IsHasChild();
                right = parentChunk.chunkTree[3].IsHasChild();

                left = leftNeighbor != 2 ? leftNeighbor : parentChunk.FindEdge(myDirection, myStack, "left") ? 1 : 0;
                myStack.Clear();
                bottom = bottomNeighbor != 2 ? bottomNeighbor : parentChunk.FindEdge(myDirection, myStack, "bottom") ? 1 : 0;
            }
            else
            {
                ///// right-bottom
                top = parentChunk.chunkTree[1].IsHasChild();
                left = parentChunk.chunkTree[2].IsHasChild();

                right = rightNeighbor != 2 ? rightNeighbor : parentChunk.FindEdge(myDirection, myStack, "right") ? 1 : 0;
                myStack.Clear();
                bottom = bottomNeighbor != 2 ? bottomNeighbor : parentChunk.FindEdge(myDirection, myStack, "bottom") ? 1 : 0;
            }
        }

        return new Vector4(right, bottom, left, top);
    }

    private bool isEdgeOnlowerLevel(Vector3 position)
    {
        Vector3 testPositon = CalculePositionOfSphere(position);
        Bounds hypBouds = new Bounds(testPositon, testPositon.normalized * scale);


        var dist = Vector3.Distance(viewerPositon, hypBouds.ClosestPoint(viewerPositon));


        if (scale * 2 > dist)
        {
            return true;
        }

        return false;
    }

    public bool FindEdge(int[] baseDirection, Stack<int[]> positionsList, string ask)
    {


        if ((string.Equals(ask, "left") && baseDirection[1] == 1) || (ask == "right" && baseDirection[1] == 0))
        {
            positionsList.Push(baseDirection);
            return FindEdgeInsite(positionsList, new int[] { 0, 1 }, ask);
        }
        else if ((ask == "top" && baseDirection[0] == 1) || (ask == "bottom" && baseDirection[0] == 0))
        {
            positionsList.Push(baseDirection);
            return FindEdgeInsite(positionsList, new int[] { 1, 0 }, ask);
        }
        else if (parentChunk != null)
        {
            positionsList.Push(baseDirection);
            int[] pom = new int[] { myDirection[0], myDirection[1] };
            return parentChunk.FindEdge(pom, positionsList, ask);
        }
        else
        {
            positionsList.Push(baseDirection);
            return topLevelSearch(positionsList, ask);

        }

    }

    public bool topLevelSearch(Stack<int[]> positionsList, string ask)
    {
        int index = 0;
        int[] from = null;
        switch (ask)
        {
            case "top":
                index = 0;
                from = new int[] { 1, 0 };
                break;
            case "right":
                index = 1;
                from = new int[] { 0, 1 };
                break;
            case "bottom":
                index = 2;
                from = new int[] { 1, 0 };
                break;
            case "left":
                index = 3;
                from = new int[] { 0, 1 };
                break;
            default:
                return false;
        }

        return topLevelneighbor[index].FindEdgeInsite(positionsList, from, ask);
    }

    public bool FindEdgeInsite(Stack<int[]> positionStack, int[] direction, string ask)
    {
        if (!isVisible)
        {
            return false;
        }

        if (positionStack.Count == 0 && chunkTree != null)
        {
            SetNeighbor(ask, 0);
            return true;
        }
        if (positionStack.Count == 1 && chunkTree == null)
        {
            SetNeighbor(ask, 1);
            return false;
        }
        if (chunkTree == null || positionStack.Count == 0)
        {
            return false;
        }

        bool isEdge = false;

        int[] backDirection = positionStack.Pop();
        int A = backDirection[0];
        int B = backDirection[1];

        if (direction[0] == 1)
        {
            if (backDirection[0] == 1)
            {
                A = 0;
            }
            else
            {
                A = 1;
            }
        }
        else
        {
            if (backDirection[1] == 1)
            {
                B = 0;
            }
            else
            {
                B = 1;
            }

        }

        isEdge = chunkTree[A * 2 + B].FindEdgeInsite(positionStack, direction, ask);

        return isEdge;


    }

    private void SetNeighbor(string ask, int value)
    {
        switch (ask)
        {
            case "top":
                bottomNeighbor = value;
                break;
            case "right":
                leftNeighbor = value;
                break;
            case "bottom":
                topNeighbor = value;
                break;
            case "left":
                rightNeighbor = value;
                break;
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

            foreach (var chunk in chunkTree)
            {

                List<Vector4>[] pom = chunk.findAllChunkToDraw();
                List<Vector4>[] pomDir = chunk.findDirection();

                if (pom == null)
                {
                    continue;
                }

                for (int i = 0; i < 4; i++)
                {
                    positionsListArray[i].AddRange(pom[i]);
                    directionListArray[i].AddRange(pomDir[i]);
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

        for (int i = 0; i < 4; i++)
        {
            chunkTree[i].MergeChunk();
        }

        chunkTree = null;
        ClearPositionAndDirection();
    }

    public void UpdateTopNeighbor(ChunkFace[] topLevelneighbor)
    {
        this.topLevelneighbor = topLevelneighbor;
    }

    public void SubDivide(Vector3 viewerPosition)
    {
        float newScale = scale * 0.5f;

        chunkTree = new ChunkFace[] {
                new ChunkFace(this, position - stepLeft  + stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {0,0 }),
                new ChunkFace(this, position + stepLeft + stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {0,1}),
                new ChunkFace(this, position - stepLeft - stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {1,0}),
                new ChunkFace(this, position + stepLeft - stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {1,1})
            };
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