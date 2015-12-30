using NUnit.Framework;

namespace TinySharp.Tests
{
    [TestFixture]
    public class TinySharpTests
    {
        private string _key;
        private Tiny _tiny;

        [SetUp]
        public void Setup()
        {
            _key = Tiny.GenerateKey();
            _tiny = new Tiny(_key);
        }

        [Test]
        public void ToHash_ReturnsString()
        {
            Assert.IsInstanceOf<string>(_tiny.ToHash(1));
        }

        [Test]
        public void ReverseHash_ReturnsInt()
        {
            var hash = _tiny.ToHash(1);
            Assert.IsInstanceOf<int>(_tiny.ReverseHash(hash));
        }

        [Test]
        public void ReverseHash_ReturnsCorrectValue()
        {
            const int id = 1234;
            var hash = _tiny.ToHash(id);
            Assert.AreEqual(id, _tiny.ReverseHash(hash));
        }

        [Test]
        public void ToHash_ReturnsCorrectValue()
        {
            const int id = 1;
            var hash = _tiny.ToHash(id);
            Assert.AreEqual(_key.Substring(1, 1), hash);
        }
    }
}
