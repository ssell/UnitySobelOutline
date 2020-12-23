using UnityEngine;

namespace VertexFragment
{
    public class MoveUpDown : MonoBehaviour
    {
        private Vector3 initialPosition;

        void Start()
        {
            initialPosition = transform.position;
        }

        void Update()
        {
            float offset = Mathf.Sin(Time.time) * 0.5f;
            transform.position = new Vector3(initialPosition.x, initialPosition.y + offset, initialPosition.z);
        }
    }
}

