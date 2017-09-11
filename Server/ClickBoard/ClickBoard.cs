using ClickBoard.Properties;
using System;
using System.Collections;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using ZeroconfService;
using QRCoder;
using System.Collections.Generic;
using System.Net.NetworkInformation;

namespace ClickBoard
{
    public partial class ClickBoard : Form
    {
        public ClickBoard()
        {
            InitializeComponent();
        }

        QRCode codeForm = new QRCode();
        ContextMenu contextMenu = new ContextMenu();

        private Socket connectedSocket;
        private short port = 6293;
        private IPAddress addr = IPAddress.Any;

        // Client socket.
        public Socket workSocket = null;
        // Size of receive buffer.
        public const int BufferSize = 256;
        // Receive buffer.
        public byte[] buffer = new byte[BufferSize];
        // Received data string.
        public StringBuilder sb = new StringBuilder();

        private Brain brain = new Brain();
        public NotifyIcon notifyIcon = new NotifyIcon();

        public bool closeFull = false;

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                Debug.WriteLine(String.Format("Bonjour Version: {0}", NetService.DaemonVersion));

                NetService service = new NetService(null, "_ClickBoard._tcp", Environment.MachineName, port);

                Hashtable dict = new Hashtable();
                dict.Add("platform", "win32");
                service.TXTRecordData = NetService.DataFromTXTRecordDictionary(dict);

                service.DidPublishService += new NetService.ServicePublished(publishService_DidPublishService);
                service.DidNotPublishService += new NetService.ServiceNotPublished(publishService_DidNotPublishService);

                service.Publish();
            }
            catch (Exception ex)
            {
                String message = ex is DNSServiceException ? "Bonjour is not installed - please install iTunes to use ClickBoard." : ex.Message;
                MessageBox.Show(message, "Critical Error", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }

            

            SetupListener();

            SetupContextMenu();

            SetupUI();
        }

        void SetupListener()
        {
            try
            {
                Socket socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                socket.Bind(new IPEndPoint(IPAddress.Any, port));
                socket.Listen(10);
                SocketAsyncEventArgs e = new SocketAsyncEventArgs();
                e.Completed += AcceptCallback;
                socket.AcceptAsync(e);
            }
            catch
            {
                MessageBox.Show("ClickBoard is already running", "Error");
                closeFull = true;
                Application.Exit();
            }
        }


        void SetupUI()
        {
            try
            {
                trackBar1.Value = Convert.ToInt32(Settings.Default.xMultiplier * 10);
                trackBar2.Value = Convert.ToInt32(Settings.Default.yMultipler * 10);
            }
            catch
            {
                trackBar1.Value = 50;
                trackBar2.Value = 50;
            }
        }

        private void AcceptCallback(object sender, SocketAsyncEventArgs e)
        {
            Debug.WriteLine("Hi");
            Socket listenSocket = (Socket)sender;
            // do
            // {

            if (InvokeRequired)
            {
                this.Invoke(new Action(() => Hide()));
            }
            try
            {
                connectedSocket = e.AcceptSocket;
                brain.connectedSocket = connectedSocket;
                brain.ApplicationController("");
                ShowBalloonToolTip("Connected", "Connected to device", 1000);
                Debug.Assert(connectedSocket != null);
                try
                {
                    // Create the state object.
                    // Begin receiving the data from the remote device.
                    SocketAsyncEventArgs socketAsynEventArgs = new SocketAsyncEventArgs();
                    socketAsynEventArgs.Completed += receiveCompleted;
                    socketAsynEventArgs.SetBuffer(new byte[BufferSize], 0, BufferSize);
                    connectedSocket.ReceiveAsync(socketAsynEventArgs);
                    //if (!connectedSocket.ReceiveAsync(socketAsynEventArgs)) { receiveCompleted(this, socketAsynEventArgs); } 
                }
                catch (Exception excpetion)
                {
                    Console.WriteLine(excpetion.ToString());
                }
            }
            catch { }
            finally
            {
                e.AcceptSocket = null; // to enable reuse
            }
            // } while (!listenSocket.AcceptAsync(e));

            listenSocket.AcceptAsync(e);
        }

        void receiveCompleted(object sender, SocketAsyncEventArgs e)
        {
            if (!connectedSocket.Connected)
            {
                Debug.WriteLine("Disconnected");
                // Connection is terminated, either by force or willingly
                //return;
            }
            byte[] data = e.Buffer;

            string responseData = System.Text.Encoding.ASCII.GetString(data, 0, e.BytesTransferred);
            e.SetBuffer(buffer, 0, BufferSize);
            if (connectedSocket.Connected)
            {
                connectedSocket.ReceiveAsync(e);
                //if (!connectedSocket.ReceiveAsync(e)) { receiveCompleted(this, e); }
            }
            if (responseData.Length > 0)
            {
                //Debug.WriteLine(responseData);
                brain.ProcessData(responseData);
            }
        }

        void SetupContextMenu()
        {
            MenuItem openMenu = new MenuItem();
            openMenu.Index = 1;
            openMenu.Text = "Show";
            openMenu.Click += new EventHandler(openMenu_click);

            MenuItem helpMenu = new MenuItem();
            helpMenu.Index = 1;
            helpMenu.Text = "Help";
            helpMenu.Click += new EventHandler(helpMenu_click);
            
            MenuItem exitMenu = new MenuItem();
            exitMenu.Index = 3;
            exitMenu.Text = "Exit";
            exitMenu.Click += new EventHandler(exitMenu_Click);

            // Initialize contextMenu1
            contextMenu.MenuItems.AddRange(
                        new System.Windows.Forms.MenuItem[] { openMenu, helpMenu, exitMenu });

            // The Icon property sets the icon that will appear
            // in the systray for this application.
            //string iconPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + @"\Resources\ClickBoard.ico";
            notifyIcon.Icon = Resources.ClickBoard;//new Icon(iconPath);

            // The ContextMenu property sets the menu that will
            // appear when the systray icon is right clicked.

            notifyIcon.ContextMenu = contextMenu;
            notifyIcon.Click += new EventHandler(notificationMenu_click);
            notifyIcon.BalloonTipClicked += new EventHandler(notificationMenu_click); ;

            notifyIcon.Visible = true;
        }

        void notificationMenu_click(object sender, EventArgs e)
        {
            this.Show();
            contextMenu.MenuItems[0].Text = "Hide";
        }

        void openMenu_click(object sender, EventArgs e)
        {
            MenuItem menuItem = contextMenu.MenuItems[0];
            if (this.Visible)
            {
                this.Hide();
                codeForm.Close();
                menuItem.Text = "Show";
            }
            else 
            {
                this.Show();
                menuItem.Text = "Hide";
            }
        }

        void exitMenu_Click(object sender, EventArgs e)
        {
            if (connectedSocket != null)
            {
                connectedSocket.Close();
                connectedSocket = null;
            }

            if (brain.connectedSocket != null)
            {
                brain.connectedSocket.Close();
                brain.connectedSocket = null;
            }
            closeFull = true;
            Application.Exit();
        }

        void ShowBalloonToolTip(string title, string text, int duration)
        {
            // The Text property sets the text that will be displayed,
            // in a tooltip, when the mouse hovers over the systray icon.
            notifyIcon.BalloonTipTitle = title;
            notifyIcon.BalloonTipText = text;
            notifyIcon.ShowBalloonTip(duration);
        }

        void publishService_DidPublishService(NetService service)
        {
            Console.WriteLine("Published Bonjour Service: domain({0}) type({1}) name({2})", service.Domain, service.Type, service.Name);
            ShowBalloonToolTip("Running", "ClickBoard is now running", 1000);
        }

        void publishService_DidNotPublishService(NetService service, DNSServiceException exception)
        {
            ShowBalloonToolTip("Error", "ClickBoard failed to start. Please try again or consult our website: www.clickboardapp.com", 1000);
            Thread.Sleep(1500);
            closeFull = true;
            Application.Exit();
        }

        private void Form1_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (connectedSocket != null)
            {
                connectedSocket.Close();
                connectedSocket = null;
            }

            if (brain.connectedSocket != null)
            {
                brain.connectedSocket.Close();
                brain.connectedSocket = null;
            }
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("http://clickboardapp.com");
        }

        private void helpMenu_click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("http://clickboardapp.com");
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (closeFull == true)
            {
                return;
            }
                try
                {
                    e.Cancel = true;
                    contextMenu.MenuItems[0].Text = "Show";
                    codeForm.Close();
                    Hide();
                }
                catch
                {

                }
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            Settings.Default.xMultiplier = trackBar1.Value / 10.0;
            Settings.Default.Save();
        }

        private void trackBar2_Scroll(object sender, EventArgs e)
        {
            Settings.Default.yMultipler = trackBar2.Value / 10.0;
            Settings.Default.Save();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            trackBar1.Value = 50; 
            trackBar2.Value = 50;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            IPHostEntry host;
            string localIP = "?";
            host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (IPAddress ip in host.AddressList)
            {
                if (ip.AddressFamily.ToString() == "InterNetwork")
                {
                    localIP = ip.ToString();
                }
            }

            QRCodeGenerator coder = new QRCodeGenerator();
            QRCodeGenerator.QRCode code = coder.CreateQrCode(localIP, QRCodeGenerator.ECCLevel.Q);

            codeForm.pictureBox1.Image = code.GetGraphic(20);
            codeForm.label1.Text = "IP Address: " + localIP;
            codeForm.ShowDialog();
        }
    }
}
