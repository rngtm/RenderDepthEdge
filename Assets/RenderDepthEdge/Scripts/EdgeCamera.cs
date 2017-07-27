namespace RenderDepthEdge
{
    using UnityEngine;

    /// <summary>
    /// 輪郭表示用のカメラにつけるコンポーネント
    /// </summary>
    public class EdgeCamera : MonoBehaviour
    {
        [SerializeField] private Camera mainCamera;
        [SerializeField] private Material edgeMat;
        [SerializeField] private Material postRenderMat;
        private RenderTexture mainCameraRenderTex;
        private RenderTexture colorTex;
        private RenderTexture depthTex;

        void Start()
        {
            // カラーバッファ用 RenderTexture
            this.colorTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            this.colorTex.Create();

            // デプスバッファ用 RenderTexture
            this.depthTex = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
            this.depthTex.Create();

            // Main Cameraの描画内容を保持する RenderTexture
            this.mainCameraRenderTex = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
            this.mainCameraRenderTex.Create();

            // Cameraの描画対象をセット
            this.mainCamera.targetTexture = this.mainCameraRenderTex;

            // edgeCameraにカラーバッファとデプスバッファをセット
            var edgeCamera = this.GetComponent<Camera>();
            edgeCamera.depthTextureMode = DepthTextureMode.Depth;
            edgeCamera.SetTargetBuffers(colorTex.colorBuffer, depthTex.depthBuffer);
        }

        void OnPostRender()
        {
            Graphics.SetRenderTarget(null); // RenderTarget無し：画面に出力される
            GL.Clear(true, true, new Color(0, 0, 0, 0));

            Graphics.Blit(this.mainCameraRenderTex, this.postRenderMat); 
            Graphics.Blit(this.depthTex, this.edgeMat);
        }
    }
}