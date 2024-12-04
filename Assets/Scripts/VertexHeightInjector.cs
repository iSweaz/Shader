using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
public class VertexHeightInjector : MonoBehaviour
{
    private MeshRenderer meshRenderer;
    private MeshFilter meshFilter;

    private bool _ready = false;

    public enum When { Never, OnEnable, OnStart }

    [SerializeField]
    private When _when = When.OnEnable;

    private void OnEnable()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        meshFilter = GetComponent<MeshFilter>();

        if (meshRenderer == null)
        {
            Debug.LogError("Missing MeshRenderer.");
            return;
        }
        if (meshFilter == null)
        {
            Debug.LogError("Missing MeshFilter.");
            return;
        }
        _ready = true;

        if (_when == When.OnEnable)
        {
            UpdateTopAndBottom();
        }
    }

    private void Start()
    {
        if (_when == When.OnStart)
        {
            UpdateTopAndBottom();
        }
    }

    public void UpdateTopAndBottom()
    {
        if (!_ready)
        {
            return;
        }
        Mesh mesh = meshFilter.sharedMesh;
        Vector3[] vertices = mesh.vertices;

        float topY = float.MinValue;
        float bottomY = float.MaxValue;

        foreach (Vector3 vertex in vertices)
        {
            float localY = vertex.y;

            if (localY > topY)
                topY = localY;

            if (localY < bottomY)
                bottomY = localY;
        }

        Material material = meshRenderer.material;
        material.SetFloat("_Top", topY);
        material.SetFloat("_Bottom", bottomY);
    }
}