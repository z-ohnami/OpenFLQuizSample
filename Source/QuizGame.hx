package ;

import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.utils.ByteArray;
import layout.LayoutItem;
import layout.LayoutManager;
import layout.LayoutType;
import openfl.Assets;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.Font;

import motion.Actuate;
import motion.easing.Quad;

class QuizGame extends Sprite
{

	private var layout:MovieClip;
	private var layoutManager:LayoutManager;

	private var _button1:Sprite;
	private var _button2:DisplayObject;
	private var _button3:DisplayObject;
	private var _messageHit:DisplayObject;
	private var _messageNoHit:DisplayObject;

	private var _quizMaster:Quiz;
	private var _quizQuestion:QuizQuestion;

	private var _question:Sprite;
	private var _questionText:TextField;

	private var _answer:Sprite;
	private var _answerText:TextField;

	private var _font:Font;
	private var _textFormat:TextFormat;

	public function new()
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(event:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);

		_quizMaster = new Quiz();

		Assets.loadLibrary ("ui", function (_) {

			var layout = Assets.getMovieClip ("ui:Layout");
			addChild (layout);

			layoutManager = new LayoutManager (640, 960);

			layoutManager.addItem (new LayoutItem (layout.getChildByName ("Button1"), LayoutType.STRETCH, LayoutType.STRETCH, false, false));
			layoutManager.addItem (new LayoutItem (layout.getChildByName ("Button2"), LayoutType.STRETCH, LayoutType.STRETCH, false, false));
			layoutManager.addItem (new LayoutItem (layout.getChildByName ("Button3"), LayoutType.STRETCH, LayoutType.STRETCH, false, false));

			layoutManager.resize (stage.stageWidth, stage.stageHeight);
			stage.addEventListener (Event.RESIZE, stage_onResize);

			_button1 = cast(layout.getChildByName ("Button1"),Sprite);
			_button1.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):Void { checkAnswer(0); });

			_button2 = layout.getChildByName ("Button2");
			_button2.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):Void { checkAnswer(1); });

			_button3 = layout.getChildByName ("Button3");
			_button3.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):Void { checkAnswer(2); });

			_question = cast(layout.getChildByName("Question"),Sprite);
			_answer = cast(layout.getChildByName("Answer"),Sprite);

			_messageHit = layout.getChildByName ("Hit");
			_messageHit.alpha = 0;
			_messageNoHit = layout.getChildByName ("NoHit");
			_messageNoHit.alpha = 0;

			setTextFormat();
			setQuiz();

		});

	}

	private function stage_onResize (event:Event):Void {

		layoutManager.resize (stage.stageWidth, stage.stageHeight);

	}

	private function setTextFormat():Void
	{
		_font = Assets.getFont ("font/HanaMinA.ttf");

		_textFormat = new TextFormat();
		_textFormat.align = TextFormatAlign.LEFT;
		_textFormat.size = 50;
		_textFormat.bold = true;
		_textFormat.font = _font.fontName;

		_questionText = new TextField();
		_questionText.width  = _question.width;
		_questionText.height = _question.height;
		_questionText.defaultTextFormat = _textFormat;
		_questionText.textColor = 0x0000FF;

		_question.addChild(_questionText);

		_answerText = new TextField();
		_answerText.width  = _answer.width;
		_answerText.height = _answer.height;
		_answerText.defaultTextFormat = _textFormat;
		_answerText.textColor = 0x0000FF;

		_answer.addChild(_answerText);

	}

	private function setQuiz():Void
	{

		_quizQuestion = _quizMaster.getQuestion();

		_questionText.text = _quizQuestion.getQuestion();
		_answerText.text = _quizQuestion.getAnswer();

	}

	private function checkAnswer(answerNum:Int):Void
	{
		playTween( _quizQuestion.isHitAnswer(answerNum) );
	}

	private function playTween(isHit:Bool):Void
	{

		var message:DisplayObject = if(isHit) _messageHit else _messageNoHit;

		Actuate.tween(message, 0.5, { alpha: 1 });
		Actuate.tween(message, 0.8, { y: -1 * message.height,alpha : 0 },false).delay(1).ease(Quad.easeInOut).onComplete(setQuiz);

	}


}

class Quiz
{
	private var _quiz:Array<QuizQuestion> = [
		new QuizQuestion("富士山の高さは？",["3,776 m","4,776 m","200 m"],0),
		new QuizQuestion("エベレストの高さは？",["7,980 m","8,850 m","8,848 m"],2),
		new QuizQuestion("高尾山の高さは？",["523 m","599 m","635 m"],1)
	];

	public function new():Void
	{
	}

	public function getQuestion():QuizQuestion
	{
		return _quiz[Std.random(_quiz.length)];
	}
}

class QuizQuestion{
	private var _question:String;
	private var _answerList:Array<String>;
	private var _rightNum:Int;

	public function new(question:String,answerList:Array<String>,rightNum:Int):Void
	{
		_question = question;
		_answerList = answerList;
		_rightNum = rightNum;
	}

	public function getQuestion():String
	{
		return _question;
	}

	public function getAnswerList():Array<String>
	{
		return _answerList;
	}

	public function getAnswer():String
	{
		var answer:String = "";
		for (i in 0..._answerList.length) {
			answer += (i+1) + ") " + _answerList[i] + "\n";
		}

		return answer;
	}

	public function isHitAnswer(answerNum:Int):Bool
	{
		if(_rightNum == answerNum) {
			return true;
		}

		return false;
	}
}