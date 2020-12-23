using UnityEngine;

namespace VertexFragment
{
    public class ShrinkAndGrow : MonoBehaviour
    {
        void Update()
        {
            float scale = (Mathf.Sin(Time.time) + 1.5f) * 0.5f;
            transform.localScale = new Vector3(scale, scale, scale);
        }
    }
}

