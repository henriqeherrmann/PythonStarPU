import starpu
import asyncio
starpu.init()
def hello():
    print ("Hello, world!")
async def main():
    fut = starpu.task_submit()(hello)
    await(fut)
asyncio.run(main())
starpu.shutdown()