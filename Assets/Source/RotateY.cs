using UnityEngine;

namespace VertexFragment
{
    public class RotateY : MonoBehaviour
    {
        void Update()
        {
            transform.RotateAround(transform.position, transform.up, Time.deltaTime * 45.0f);
        }
    }

}