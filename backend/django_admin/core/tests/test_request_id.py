import logging

from django.http import HttpResponse
from django.test import RequestFactory, SimpleTestCase

from core.logging import RequestIDFilter, request_id_context
from core.middleware import RequestIDMiddleware


class RequestIDMiddlewareTests(SimpleTestCase):
	def setUp(self):
		self.factory = RequestFactory()

	def test_propagates_request_id_to_logs_and_response(self):
		observed_request_ids = []

		def get_response(request):
			record = logging.LogRecord('test', logging.INFO, __file__, 1, 'request', (), None)
			RequestIDFilter().filter(record)
			observed_request_ids.append((request.request_id, record.request_id))
			return HttpResponse('ok')

		request = self.factory.get('/health/', HTTP_X_REQUEST_ID='client-trace-123')
		response = RequestIDMiddleware(get_response)(request)

		self.assertEqual(response['X-Request-ID'], 'client-trace-123')
		self.assertEqual(observed_request_ids, [('client-trace-123', 'client-trace-123')])
		self.assertEqual(request_id_context.get(), '-')

	def test_replaces_malformed_request_id(self):
		request = self.factory.get('/health/')
		request.META['HTTP_X_REQUEST_ID'] = 'bad trace value\r\nInjected: true'
		response = RequestIDMiddleware(lambda _request: HttpResponse('ok'))(request)

		self.assertRegex(response['X-Request-ID'], r'^[0-9a-f-]{36}$')
		self.assertEqual(request_id_context.get(), '-')