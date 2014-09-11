package org.xtext.xrobot.camera;

import static org.xtext.xrobot.camera.GeometryUtils.distance;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridLayout;
import java.awt.Panel;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.swing.JButton;
import javax.swing.JColorChooser;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.highgui.VideoCapture;
import org.opencv.imgproc.Imgproc;

public class TriangleScanner {

	static  {
		System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
	}

	private TriangleScanParameters[] allParams = new TriangleScanParameters[] {
		new TriangleScanParameters("Xtext", 0, new Scalar(239, 188, 0), new Scalar(255,248,89), 115),
		new TriangleScanParameters("Xtend", 1, new Scalar(88, 98, 165), new Scalar(140, 200, 255), 115)
	};
	
	private volatile DisplayedType displayedType = DisplayedType.VIDEO;
	private int uiCurrentRobot = 0;
	private JLabel framerateLabel;
	private JLabel qualityLabel;
	private JLabel numContoursLabel;
	private JLabel maxContoursLabel;

	private JSpinner minContourPointsSpinner;
	

	public void run(CameraServer server) {
		VideoCapture videoCapture = new VideoCapture();
		if(!videoCapture.open(0)) {
			throw new IllegalStateException("Cannot open camera");
		}
		Mat videoImage = new Mat();
		videoCapture.read(videoImage);
		ImagePanel imagePanel = new ImagePanel(videoImage);
		showFrame(imagePanel);
		QualityMeter qualityMeter = new QualityMeter(100);
		do {
			long startTime = System.currentTimeMillis();
			Mat displayedImage = null;
			int currentRobot = uiCurrentRobot;
			Triangle[] triangles = new Triangle[2];
			for(TriangleScanParameters params: allParams) {
				// filter image by color
				Mat colorFilteredImage = new Mat();
				Core.inRange(videoImage, params.getMaxTriangleColor(), params.getMaxTriangleColor(), colorFilteredImage);
				
				Mat dilatedImage = new Mat();
				Imgproc.dilate(colorFilteredImage, dilatedImage, Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(3,3)));
				
				// detect edges
				Mat edgeDetectedImage = new Mat();
				Imgproc.Canny(dilatedImage, edgeDetectedImage, 50, 250);
	
				if(params.getId() == currentRobot) {
					switch (displayedType) {
					case VIDEO:
						displayedImage = videoImage.clone();
						break;
					case FILTERED:
						displayedImage = new Mat();
						Imgproc.cvtColor(colorFilteredImage, displayedImage, Imgproc.COLOR_GRAY2BGR);
						break;
					case DILATED:
						displayedImage = new Mat();
						Imgproc.cvtColor(dilatedImage, displayedImage, Imgproc.COLOR_GRAY2BGR);
						break;
					case CONTOUR:
						displayedImage = new Mat();
						Imgproc.cvtColor(edgeDetectedImage, displayedImage, Imgproc.COLOR_GRAY2BGR);
						break;
					}
				}
				
				// find contours
				List<MatOfPoint> contours = new ArrayList<MatOfPoint>();
				Imgproc.findContours(edgeDetectedImage, contours, new Mat(), Imgproc.RETR_EXTERNAL,
						Imgproc.CHAIN_APPROX_NONE);
				List<MatOfPoint> biggestContours = new ArrayList<MatOfPoint>();
				int maxCountourPoints = 0;
				for (int i = 0; i < contours.size(); ++i) {
					int rows = contours.get(i).rows();
					if (rows > params.getMinContourPoints()) {
						biggestContours.add(contours.get(i));
						if(params.getId() == currentRobot) 
							Imgproc.drawContours(displayedImage, contours, i, new Scalar(0, 225, 0));
					}
					if(maxCountourPoints < rows) 
						maxCountourPoints = rows;
				}
				if(params.getId() == currentRobot) {
					numContoursLabel.setText(String.format("%5d", maxCountourPoints));
					maxContoursLabel.setText(String.format("%3d", biggestContours.size()));
				}
				if (biggestContours.size() > 0 && biggestContours.size() < 200) {
					// approximate contours as polygons
					List<Point> polyPoints = new ArrayList<Point>();
					for (MatOfPoint maxContour : biggestContours) {
						MatOfPoint2f poly = new MatOfPoint2f();
						Imgproc.approxPolyDP(new MatOfPoint2f(maxContour.toArray()), poly, 4, true);
						Point[] polyAsArray = poly.toArray();
						if(params.getId() == currentRobot) 
							Core.polylines(displayedImage, Collections.singletonList(new MatOfPoint(polyAsArray)), true,
									new Scalar(0, 0, 255));
						for (Point p : polyAsArray) {
							polyPoints.add(p);
						}
					}
					// find triangle
					triangles[params.getId()] = approximateTriangle(params.getId(), polyPoints);
					qualityMeter.success();
				} else {
					qualityMeter.failure();
				}
			}
			if(server != null)
				server.sendPositions(triangles, allParams);
			for(Triangle triangle: triangles) {
				if(triangle != null) {
					// display triangles
					Point forwardCorner = triangle.getForwardCorner();
					Core.line(displayedImage, triangle.getMidpoint(), forwardCorner, new Scalar(255, 0, 0));
					for (Point p : triangle.getCorners()) {
						if (p != triangle.getForwardCorner())
							Core.line(displayedImage, p, triangle.getForwardCorner(), new Scalar(255, 0, 0));
					}
				}
			}
			// display image
			videoImage = new Mat();
			imagePanel.update(displayedImage);
			long duration = System.currentTimeMillis() - startTime;
			framerateLabel.setText((1000 / duration) + "fps");
			qualityLabel.setText(String.format("%2.0f", qualityMeter.getRate() * 100) + "%");
			videoCapture.read(videoImage);
		} while (true);
	}

	private Triangle approximateTriangle(int robot, List<Point> polyPoints) {
		Point left = new Point(Double.MAX_VALUE, 0);
		Point right = new Point(Double.MIN_VALUE, 0);
		Point top = new Point(0, Double.MAX_VALUE);
		Point bottom = new Point(0, Double.MIN_VALUE);
		for (Point p : polyPoints) {
			if (left.x > p.x)
				left = p;
			if (right.x < p.x)
				right = p;
			if (top.y > p.y)
				top = p;
			if (bottom.y < p.y)
				bottom = p;
		}
		Set<Point> corners = new LinkedHashSet<Point>();
		corners.add(left);
		corners.add(bottom);
		corners.add(right);
		corners.add(top);
		if (corners.size() == 4) {
			List<Point> points = new ArrayList<Point>(corners);
			double minDist = Double.MAX_VALUE;
			int minIndex = -1;
			for (int i = 0; i < 4; ++i) {
				double dist = distance(points.get(i), points.get((i + 1) % 4));
				if (dist < minDist) {
					minDist = dist;
					minIndex = i;
				}
			}
			Point remove0 = points.get(minIndex);
			Point remove1 = points.get((minIndex + 1) % 4);
			corners.remove(remove0);
			corners.remove(remove1);
			corners.add(new Point((remove0.x + remove1.x) / 2, (remove0.y + remove1.y) / 2));
		}
		return new Triangle(robot, corners);
	}


	public void showFrame(final ImagePanel imagePanel) {
		JFrame frame = new JFrame();
		frame.getContentPane().setLayout(new BorderLayout());
		frame.getContentPane().add(imagePanel, BorderLayout.CENTER);
		JPanel buttons = new JPanel();
		buttons.setLayout(new GridLayout());
		JButton calibrate = new JButton("Calibrate");
		final ScalarColorChooser minColorChooser = new ScalarColorChooser("Min color", true);
		final ScalarColorChooser maxColorChooser = new ScalarColorChooser("Max color", false);
		calibrate.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				minColorChooser.getDialog(imagePanel).setVisible(true);
				maxColorChooser.getDialog(imagePanel).setVisible(true);
			}
		});
		buttons.add(calibrate);
		String[] names = new String[allParams.length];
		for(TriangleScanParameters params: allParams) {
			names[params.getId()] = params.getName();
		}
		final JComboBox<String> robotCombo = new JComboBox<String>(names);
		robotCombo.setEditable(false);
		buttons.add(robotCombo);
		final JComboBox<DisplayedType> displayedTypeCombo = new JComboBox<DisplayedType>(DisplayedType.values());
		displayedTypeCombo.setEditable(false);
		displayedTypeCombo.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				displayedType = (DisplayedType) displayedTypeCombo.getSelectedItem();
			}
		});
		buttons.add(displayedTypeCombo);
		framerateLabel = new JLabel("framerate");
		buttons.add(framerateLabel);
		qualityLabel = new JLabel("quality");
		buttons.add(qualityLabel);
		minContourPointsSpinner = new JSpinner(new SpinnerNumberModel(allParams[uiCurrentRobot].getMinContourPoints(), 0, 1000, 1));
		minContourPointsSpinner.addChangeListener(new ChangeListener() {
			@Override
			public void stateChanged(ChangeEvent e) {
				allParams[uiCurrentRobot].setMinContourPoints((Integer) minContourPointsSpinner.getValue());
			}
		});
		buttons.add(minContourPointsSpinner);
		numContoursLabel = new JLabel("contours");
		buttons.add(numContoursLabel);
		maxContoursLabel = new JLabel("contour points");
		buttons.add(maxContoursLabel);
		robotCombo.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				uiCurrentRobot = robotCombo.getSelectedIndex();
				minColorChooser.update();
				maxColorChooser.update();
				minContourPointsSpinner.setValue(allParams[uiCurrentRobot].getMinContourPoints());
			}
		});
		frame.getContentPane().add(buttons, BorderLayout.PAGE_END);
		frame.pack();
		frame.setVisible(true);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}

	@SuppressWarnings("serial")
	class ScalarColorChooser extends JColorChooser {
		private String name;
		private boolean isMinimum;
		private JDialog dialog;

		public ScalarColorChooser(String name, boolean isMinimum) {
			this.isMinimum = isMinimum;
			this.name = name;
			
			getSelectionModel().addChangeListener(new ChangeListener() {
				@Override
				public void stateChanged(ChangeEvent e) {
					Color color = getColor();
					Scalar scalar = getScalar();
					scalar.val[0] = color.getBlue();
					scalar.val[1] = color.getGreen();
					scalar.val[2] = color.getRed();
				}
			});
		}
		
		private Scalar getScalar() {
			return (isMinimum)
					? allParams[uiCurrentRobot].getMinTriangleColor()
					: allParams[uiCurrentRobot].getMaxTriangleColor();
		}
		
		public void update() {
			Scalar scalar = getScalar();
			setColor(new Color((int) scalar.val[2], (int) scalar.val[1], (int) scalar.val[0]));
		}

		public JDialog getDialog(Component parent) {
			if(dialog == null) {
				dialog = JColorChooser.createDialog(parent, name, false, this, null, null);
			}
			return dialog;
		}
	}

	enum DisplayedType {
		VIDEO, FILTERED, DILATED, CONTOUR
	}

	@SuppressWarnings("serial")
	class ImagePanel extends Panel {
		BufferedImage image;

		public ImagePanel(Mat m) {
			super();
			update(m);
			addMouseListener(new MouseAdapter() {
				@Override
				public void mouseClicked(MouseEvent e) {
					if(e.getClickCount() == 2) {
						int rgb = image.getRGB(e.getX(), e.getY());
						Color pickedColor = new Color(rgb);
						Scalar minTriangleColor = allParams[uiCurrentRobot].getMinTriangleColor(); 
						Scalar maxTriangleColor = allParams[uiCurrentRobot].getMaxTriangleColor(); 
						minTriangleColor.val[0] = makeValid(0.8 * pickedColor.getBlue());
						minTriangleColor.val[1] = makeValid(0.8 * pickedColor.getGreen());
						minTriangleColor.val[2] = makeValid(0.8 * pickedColor.getRed());
						maxTriangleColor.val[0] = makeValid(1.2 * pickedColor.getBlue());
						maxTriangleColor.val[1] = makeValid(1.2 * pickedColor.getGreen());
						maxTriangleColor.val[2] = makeValid(1.2 * pickedColor.getRed());
					}
				}
			});
		}
		
		private int makeValid(double color) {
			return Math.min(255, Math.max(0, (int)color));
		}

		@Override
		public Dimension getPreferredSize() {
			return new Dimension(image.getWidth(), image.getHeight());
		}

		public void update(Mat m) {
			int type = BufferedImage.TYPE_BYTE_GRAY;
			if (m.channels() > 1) {
				type = BufferedImage.TYPE_3BYTE_BGR;
			}
			int bufferSize = m.channels() * m.cols() * m.rows();
			byte[] b = new byte[bufferSize];
			m.get(0, 0, b);
			BufferedImage image = new BufferedImage(m.cols(), m.rows(), type);
			final byte[] targetPixels = ((DataBufferByte) image.getRaster().getDataBuffer()).getData();
			System.arraycopy(b, 0, targetPixels, 0, b.length);
			this.image = image;
			repaint();
		}
		
		@Override
		public void paint(Graphics g) {
			g.drawImage(image, 0, 0, null);
		}
	}
}
