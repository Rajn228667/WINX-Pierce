export const metadata = {
  title: 'Политика конфиденциальности — hikmart.kz',
}

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 md:px-6 md:py-14">
      <h1 className="mb-8 font-sans text-3xl font-bold text-foreground md:text-4xl text-balance">
        Политика конфиденциальности
      </h1>
      <div className="flex flex-col gap-6 leading-relaxed text-muted-foreground">
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">1. Общие положения</h2>
          <p>
            Настоящая Политика конфиденциальности определяет порядок обработки и защиты персональных данных
            пользователей сайта hikmart.kz. Используя сайт, вы соглашаетесь с условиями настоящей Политики.
          </p>
        </section>
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">2. Собираемые данные</h2>
          <p>
            Мы можем собирать следующие данные: имя, номер телефона, адрес электронной почты, адрес доставки, а
            также данные, которые вы указываете при оформлении заказа или отправке заявки на консультацию.
          </p>
        </section>
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">3. Цели обработки данных</h2>
          <p>
            Персональные данные используются для обработки заказов, связи с клиентом, подбора оборудования,
            информирования об акциях и улучшения качества обслуживания.
          </p>
        </section>
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">4. Защита данных</h2>
          <p>
            Мы принимаем необходимые организационные и технические меры для защиты персональных данных от
            неправомерного доступа, изменения, раскрытия или уничтожения. Данные не передаются третьим лицам, за
            исключением случаев, предусмотренных законодательством Республики Казахстан.
          </p>
        </section>
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">5. Файлы cookie</h2>
          <p>
            Сайт использует файлы cookie для сохранения настроек пользователя (язык интерфейса, содержимое
            корзины). Вы можете отключить cookie в настройках браузера, однако это может повлиять на работу сайта.
          </p>
        </section>
        <section>
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">6. Контакты</h2>
          <p>
            По вопросам обработки персональных данных обращайтесь: Казахстан, Шымкент, проспект Тауке Хана 143,
            телефон +7 (776) 106-11-77.
          </p>
        </section>
        <p className="text-sm">
          Цены на сайте не являются публичной офертой, уточняйте актуальную стоимость у менеджера.
        </p>
      </div>
    </div>
  )
}
